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
    uses: zentable
    percent_column_names: ['Proportion']


"""
__author__ = 'Paul Landes'

from typing import Dict, List, Sequence, Set, Union, Tuple
from dataclasses import dataclass, field
import sys
import logging
import yaml
import re
from itertools import chain
from io import TextIOWrapper
from pathlib import Path
from datetime import datetime
from tabulate import tabulate
import itertools as it
import plac
import pandas as pd
from zensols.persist import persisted

logger = logging.getLogger(__name__)


@dataclass
class Table(object):
    """Generates a Zensols styled Latex table from a CSV file.

    """
    path: str = field()
    """The path to the CSV file to make a latex table."""

    name: str = field()
    """The name of the table, also used as the label."""

    caption: str = field()
    """The human readable string used to the caption in the table."""

    placement: str = field(default=None)
    """The placement of the table."""

    placement_number: int = field(default=1)
    """The number of the placement argument to pass in the Latex command."""

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

    @property
    def is_placement_variable(self) -> bool:
        return self.placement == 'VAR'

    def _placement_param(self, add_brackets: bool = True) -> str:
        if self.placement is None:
            placement = ''
        elif self.is_placement_variable:
            arg_num = self.placement_number
            placement = f'#{arg_num}'
        else:
            placement = self.placement
        if add_brackets and len(placement) > 0:
            placement = f'[{placement}]'
        return placement

    @property
    def params(self) -> Dict[str, str]:
        """Return the parameters used for creating the table.

        """
        return {'tabname': self.name,
                'latex_environment': self.latex_environment,
                'caption': self.caption,
                'placement': self._placement_param(),
                'columns': self.columns,
                'size': self.size}

    @property
    def header(self) -> str:
        """Return the Latex environment header.

        """
        return """\\begin{%(latex_environment)s}%(placement)s{%(tabname)s}%%
{%(caption)s}{\\%(size)s}{%(columns)s}""" % self.params

    @property
    @persisted('_dataframe')
    def dataframe(self) -> pd.DataFrame:
        """Return the pandas Dataframe that holds the CSV data.

        """
        df = pd.read_csv(self.path, **self.read_kwargs)
        for col in self.percent_column_names:
            df[col] = df[col].apply(lambda s: s.replace('%', '\\%'))
        return df

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
        return 'zzvarcoltable'

    @property
    def header(self):
        params = self.params
        width = '\\columnwidth' if self.single_column else '\\textwidth'
        params['width'] = width
        params['placement'] = self._placement_param(False)
        return """\\begin{%(latex_environment)s}[%(width)s]{%(placement)s}{%(tabname)s}{%(caption)s}%%
{\\%(size)s}{%(columns)s}""" % params

    @property
    def columns(self):
        df = self.dataframe
        i = self.slack_col
        cols = ('l' * (df.shape[1] - 1))
        cols = cols[:i] + 'X' + cols[i:]
        cols = '|' + '|'.join(cols) + '|'
        return cols


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

    def _write_footer(self):
        pass

    def _write_table(self, table):
        writer = self.writer
        df: pd.DataFrame = table.dataframe
        if table.replace_nan is not None:
            df = df.fillna(table.replace_nan)
        if len(table.blank_columns) > 0:
            cols = df.columns.to_list()
            for i in table.blank_columns:
                cols[i] = ''
            df.columns = cols
        if len(table.bold_cells) > 0:
            for r, c in table.bold_cells:
                df.iloc[r, c] = '\\textbf{' + str(df.iloc[r, c]) + '}'
        cols = [tuple(map(lambda c: f'\\textbf{{{c}}}', df.columns))]
        data = it.chain(cols, map(lambda x: x[1].tolist(), df.iterrows()))
        params = dict(tablefmt='latex_raw', headers='firstrow')
        params.update(table.write_kwargs)
        lines = tabulate(data, **params).split('\n')
        params = dict(table.params)
        params['cvars'] = '[1]' if table.is_placement_variable else ''
        writer.write('\n\\newcommand{\\%(tabname)s}%(cvars)s{%%\n' % params)
        writer.write(table.header)
        writer.write('\n')
        for lix, ln in enumerate(lines[1:-1]):
            writer.write(ln + '\n')
            if (lix - 2) in table.hlines:
                writer.write('\\hline  \n')
            if (lix - 2) in table.double_hlines:
                writer.write('\\hline \\hline \n')
        writer.write('\\end{%s}}\n' % table.latex_environment)

    def write(self):
        """Write the Latex table to the writer given in the initializer.

        """
        self._write_header()
        for table in self.tables:
            self._write_table(table)
        self._write_footer()


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


@plac.annotations(
    table_path=('The table definitions YAML path location.',
                'positional', None, str),
    output_file=('The output file .sty file.', 'positional', None, str))
def write_latex_table(table_path, output_file):
    """Generate Latex tables in a .sty file from CSV files.  The paths to the CSV
    files to create tables from and their metadata is given as a YAML
    configuration file."""
    logging.basicConfig(level=logging.INFO,
                        format='mklatextbl: %(message)s')
    mng = TableFileManager(Path(table_path))
    logger.info(f'preparing package {mng.package_name}')
    with open(output_file, 'w') as f:
        tab = CsvToLatexTable(mng.tables, mng.package_name, f)
        tab.write()
    logger.info(f'wrote {output_file}')


if __name__ == '__main__':
    plac.call(write_latex_table)
