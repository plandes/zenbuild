#!/usr/bin/env python

"""Generate Latex tables in a .sty file from CSV files.  The paths to the CSV
files to create tables from and their metadata is given as a YAML configuration
file.

Example::
    latextablenamehere:
        type: slack
        slack_col: 0
        path: ../config/table-name.csv
        caption: Some Caption
        placement: t!
        size: small
        single_column: true
        percent_column_names: ['Proportion']


"""
__author__ = 'Paul Landes'

from typing import Dict, List, Sequence, Set, Union, Tuple, Any, ClassVar
from dataclasses import dataclass, field
import sys
import logging
import yaml
import re
from itertools import chain
from io import TextIOWrapper, StringIO
from pathlib import Path
from datetime import datetime
from tabulate import tabulate
import itertools as it
import plac
import pandas as pd
from zensols.persist import persisted

logger = logging.getLogger(__name__)


@dataclass
class VariableParam(object):
    name: str = field()
    index_format: str = field(default='#{index}')
    value_format: str = field(default='\\{val}')


@dataclass
class Table(object):
    """Generates a Zensols styled Latex table from a CSV file.

    """
    _VARIABLE: ClassVar[str] = 'VAR'
    _VARIABLE_ATTRIBUTES: ClassVar[Tuple[VariableParam]] = (
        VariableParam('placement'),
        VariableParam('size'))

    path: str = field()
    """The path to the CSV file to make a latex table."""

    name: str = field()
    """The name of the table, also used as the label."""

    caption: str = field()
    """The human readable string used to the caption in the table."""

    placement: str = field(default=None)
    """The placement of the table."""

    size: str = field(default='normalsize')
    """The size of the table, and one of::
            Huge
            huge
            LARGE
            Large
            large
            normalsize (default)
            small
            footnotesize
            scriptsize
            tiny

    """
    uses: Sequence[str] = field(default=('zentable',))
    """Comma separated list of packages to use."""

    single_column: bool = field(default=True)
    """Makes the table one column wide in a two column.  Setting this to false
    generates a ``table*`` two column table, which won't work in beamer
    (slides) document types.

    """
    hlines: Union[Sequence[Set[int]]] = field(default_factory=set)
    """Indexes of rows to put horizontal line breaks."""

    double_hlines: Union[Sequence[Set[int]]] = field(default_factory=set)
    """Indexes of rows to put double horizontal line breaks."""

    column_removes: List[str] = field(default_factory=list)
    """The name of the columns to remove from the table, if any.

    """
    percent_column_names: Sequence[str] = field(default=())
    """Column names that have a percent sign to be escaped."""

    read_kwargs: Dict[str, str] = field(default_factory=dict)
    """Keyword arguments used in the :meth:`~pandas.read_csv` call when reading the
    CSV file.

    """
    write_kwargs: Dict[str, str] = field(default_factory=dict)
    """Keyword arguments used in the :meth:`~tabulate.tabulate` call when writing
    the table.

    """
    replace_nan: str = field(default=None)
    """Replace NaN values with a the value of this field as :meth:`tabulate` is not
    using the missing value due to some bug I assume.

    """
    blank_columns: List[int] = field(default=())
    """A list of column indexes to set to the empty string (i.e. 0th to fixed the
    ``Unnamed: 0`` issues).

    """
    bold_cells: List[Tuple[int, int]] = field(default=())
    """A list of row/column cells to bold."""

    index_col_name: str = field(default=None)
    """If set, add an index column with the given name."""

    df_code: str = field(default=None)
    """Python code executed that manipulates the table's dataframe.  The code has a
    local ``df`` variable and the returned value is used as the replacement.
    This is usually a one-liner used to subset the data etc.

    """
    def __post_init__(self):
        if isinstance(self.uses, str):
            self.uses = re.split(r'\s*,\s*', self.uses)
        if isinstance(self.hlines, (tuple, list)):
            self.hlines = set(self.hlines)
        if isinstance(self.double_hlines, (tuple, list)):
            self.double_hlines = set(self.double_hlines)

    @property
    def latex_environment(self) -> str:
        """Return the latex environment for the table.

        """
        tab: str
        if self.single_column:
            tab = 'zztable'
        else:
            if self.placement is None:
                tab = 'zztabletcol'
            else:
                tab = 'zztabletcolplace'
        return tab

    @property
    def columns(self) -> str:
        """Return the columns field in the Latex environment header.

        """
        df = self.dataframe
        cols = 'l' * df.shape[1]
        cols = '|' + '|'.join(cols) + '|'
        return cols

    def get_cmd_args(self, add_brackets: bool) -> Dict[str, str]:
        args = {}
        var: VariableParam
        for i, var in enumerate(self._VARIABLE_ATTRIBUTES):
            attr: str = var.name
            val = getattr(self, attr)
            if val is None:
                val = ''
            elif val == self._VARIABLE:
                val = var.index_format.format(index=(i + 1), val=val, var=var)
            else:
                val = var.value_format.format(index=(i + 1), val=val, var=var)
            if add_brackets and len(val) > 0:
                val = f'[{val}]'
            args[attr] = val
        return args

    @property
    @persisted('_var_args')
    def var_args(self) -> Tuple[str]:
        var = tuple(map(lambda a: (a, getattr(self, a.name)),
                        self._VARIABLE_ATTRIBUTES))
        return tuple(map(lambda x: x[0],
                         filter(lambda x: x[1] == self._VARIABLE, var)))

    def get_params(self, add_brackets: bool) -> Dict[str, str]:
        """Return the parameters used for creating the table.

        """
        params = {'tabname': self.name,
                  'latex_environment': self.latex_environment,
                  'caption': self.caption,
                  'columns': self.columns}
        params.update(self.get_cmd_args(add_brackets))
        return params

    @property
    def header(self) -> str:
        """Return the Latex environment header.

        """
        return """\\begin{%(latex_environment)s}[%(placement)s]{%(tabname)s}%%
{%(caption)s}{%(size)s}{%(columns)s}""" % self.get_params(False)

    @property
    @persisted('_dataframe')
    def dataframe(self) -> pd.DataFrame:
        """Return the pandas Dataframe that holds the CSV data.

        """
        df = pd.read_csv(self.path, **self.read_kwargs)
        for col in self.percent_column_names:
            df[col] = df[col].apply(lambda s: s.replace('%', '\\%'))
        df = df.drop(columns=self.column_removes)
        if self.df_code is not None:
            df = eval(self.df_code)
        if self.index_col_name is not None:
            df = df.copy()
            df[self.index_col_name] = range(1, len(df) + 1)
            cols = df.columns.to_list()
            cols = [cols[-1]] + cols[:-1]
            df = df[cols]
        return df

    def _get_rows(self, df: pd.DataFrame) -> List[List[Any]]:
        cols = [tuple(map(lambda c: f'\\textbf{{{c}}}', df.columns))]
        return it.chain(cols, map(lambda x: x[1].tolist(), df.iterrows()))

    def _get_tabulate_params(self) -> Dict[str, Any]:
        params = dict(tablefmt='latex_raw', headers='firstrow')
        params.update(self.write_kwargs)
        return params

    def write(self, writer: TextIOWrapper):
        df: pd.DataFrame = self.dataframe
        if self.replace_nan is not None:
            df = df.fillna(self.replace_nan)
        if len(self.blank_columns) > 0:
            cols = df.columns.to_list()
            for i in self.blank_columns:
                cols[i] = ''
            df.columns = cols
        if len(self.bold_cells) > 0:
            for r, c in self.bold_cells:
                df.iloc[r, c] = '\\textbf{' + str(df.iloc[r, c]) + '}'
        data = self._get_rows(df)
        params: Dict[str, Any] = self._get_tabulate_params()
        lines = tabulate(data, **params).split('\n')
        params = dict(self.get_params(True))
        params['cvars'] = ''
        n_var_args = len(self.var_args)
        if n_var_args > 0:
            params['cvars'] = f'[{n_var_args}]'
        writer.write('\n\\newcommand{\\%(tabname)s}%(cvars)s{%%\n' % params)
        writer.write(self.header)
        writer.write('\n')
        for lix, ln in enumerate(lines[1:-1]):
            writer.write(ln + '\n')
            if (lix - 2) in self.hlines:
                writer.write('\\hline  \n')
            if (lix - 2) in self.double_hlines:
                writer.write('\\hline \\hline \n')
        writer.write('\\end{%s}}\n' % self.latex_environment)

    def __str__(self):
        return f'{self.name}: env={self.latex_environment}, size={self.size}'


@dataclass
class SlackTable(Table):
    """An instance of the table that fills up space based on the widest column.

    """
    slack_col: int = field(default=0)
    """Which column elastically grows or shrinks to make the table fit."""

    @property
    def latex_environment(self):
        return 'zzvarcoltable' if self.single_column else 'zzvarcoltabletcol'

    @property
    def header(self) -> str:
        params = self.get_params(False)
        width = '\\columnwidth' if self.single_column else '\\textwidth'
        params['width'] = width
        return """\\begin{%(latex_environment)s}[%(width)s]{%(placement)s}{%(tabname)s}{%(caption)s}%%
{%(size)s}{%(columns)s}""" % params

    @property
    def columns(self) -> str:
        df = self.dataframe
        i = self.slack_col
        cols = ('l' * (df.shape[1] - 1))
        cols = cols[:i] + 'X' + cols[i:]
        cols = '|' + '|'.join(cols) + '|'
        return cols


@dataclass
class LongTable(SlackTable):
    @property
    def latex_environment(self):
        return 'zzvarcoltabletcollong'

    @property
    def header(self):
        df = self.dataframe
        hcols = ' & '.join(map(lambda c: f'\\textbf{{{c}}}', df.columns))
        return f'{super().header}{{{hcols}}}{{{df.shape[1]}}}'

    def _get_rows(self, df: pd.DataFrame) -> List[List[Any]]:
        df: pd.DataFrame = self.dataframe
        return map(lambda x: x[1].tolist(), df.iterrows())

    def _get_tabulate_params(self) -> Dict[str, Any]:
        params = super()._get_tabulate_params()
        del params['headers']
        return params

    def write(self, writer: TextIOWrapper):
        sio = StringIO()
        super().write(sio)
        sio.seek(0)
        hlremove = 1
        for line in map(str.strip, sio.readlines()):
            if line == '\\hline' and hlremove > 0:
                hlremove += 1
                continue
            writer.write(line + '\n')


class CsvToLatexTable(object):
    """Generate a Latex table from a CSV file.

    """
    def __init__(self, tables: List[Table], package_name: str,
                 writer: TextIOWrapper = sys.stdout):
        """Initialize.

        :param tables: a list of table instances to create Latex table
                       definitions

        :param package_name the name Latex .sty package

        :param writer: the stream to write to

        """
        self.tables = tables
        self.package_name = package_name
        self.writer = writer

    def _write_header(self):
        date = datetime.now().strftime('%Y/%m/%d')
        self.writer.write("""\\NeedsTeXFormat{LaTeX2e}
\\ProvidesPackage{%(package_name)s}[%(date)s Tables]

""" % {'date': date, 'package_name': self.package_name})
        uses: Set[str] = set(chain.from_iterable(
            map(lambda t: t.uses, self.tables)))
        for use in sorted(uses):
            self.writer.write(f'\\usepackage{{{use}}}\n')

    def write(self):
        """Write the Latex table to the writer given in the initializer.

        """
        self._write_header()
        for table in self.tables:
            table.write(self.writer)


class TableFileManager(object):
    """Reads the table definitions file and writes a Latex .sty file of the
    generated tables from the CSV data.

    """
    FILE_NAME_REGEX = re.compile(r'(.+)\.yml')
    PACKAGE_FORMAT = '{name}'

    def __init__(self, table_path: Path):
        """
        :param table_path: the path to the table YAML defintiions file
        """
        self.table_path = table_path

    @property
    @persisted('_package_name')
    def package_name(self):
        fname = self.table_path.name
        m = self.FILE_NAME_REGEX.match(fname)
        if m is None:
            raise ValueError(f'does not appear to be a YAML file: {fname}')
        return self.PACKAGE_FORMAT.format(**{'name': m.group(1)})

    @property
    def tables(self):
        logger.info(f'reading table definitions file {self.table_path}')
        tables = []
        with open(self.table_path) as f:
            content = f.read()
        tdefs = yaml.load(content, yaml.FullLoader)
        for name, td in tdefs.items():
            if 'type' in td:
                cls_name = td['type'].capitalize() + 'Table'
                del td['type']
            else:
                cls_name = 'Table'
            cls = globals()[cls_name]
            td['name'] = name
            tables.append(cls(**td))
        return tables


@dataclass
class Application(object):
    _TABLE_FILE_REGEX: ClassVar[re.Pattern] = re.compile(r'^.+-table\.yml$')
    table_path: Path
    output_path: Path

    def _process_file(self, table_file: Path, output_file: Path):
        mng = TableFileManager(Path(table_file))
        logger.info(f'{table_file} -> {output_file}, pkg={mng.package_name}')
        with open(output_file, 'w') as f:
            tab = CsvToLatexTable(mng.tables, mng.package_name, f)
            tab.write()
        logger.info(f'wrote {output_file}')

    def __call__(self):
        if self.table_path.is_dir() and not self.output_path.is_dir() or \
           not self.table_path.is_dir() and self.output_path.is_dir():
            raise ValueError(
                'Both parameters must both be either files or directories')
        if self.table_path.is_dir():
            tfiles = filter(lambda p: self._TABLE_FILE_REGEX.match(p.name),
                            self.table_path.iterdir())
            tfile: Path
            for tfile in tfiles:
                ofile: Path = self.output_path / f'{tfile.stem}.sty'
                self._process_file(tfile, ofile)
        else:
            self._process_file(self.table_path, self.output_path)


@plac.annotations(
    table_path=('The table definitions YAML path location or directory.',
                'positional', None, str),
    output_path=('The output file .sty file or directory.',
                 'positional', None, str))
def write_latex_table(table_path, output_path):
    """Generate Latex tables in a .sty file from CSV files.  The paths to the
    CSV files to create tables from and their metadata is given as a YAML
    configuration file.  Paraemters are both files or both directories.  When
    using directories, only files that match *-table.yml are considered.

    """
    logging.basicConfig(level=logging.INFO, format='mklatextbl: %(message)s')
    app = Application(*map(Path, (table_path, output_path)))
    app()


if __name__ == '__main__':
    plac.call(write_latex_table)
