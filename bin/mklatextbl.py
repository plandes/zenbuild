#!/usr/bin/env python

"""Generate Latex tables in a .sty file from CSV files.  The paths to the CSV
files to create tables from and their metadata is given as a YAML configuration
file.

"""
__author__ = 'Paul Landes'

from typing import Dict, List
from dataclasses import dataclass, field
import sys
import logging
import yaml
import re
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
    single_column: bool = field(default=False)
    """Makes the table one column wide in a two column."""

    @property
    def latex_environment(self) -> str:
        """Return the latex environment for the table.

        """
        if self.single_column:
            return 'zztable'
        else:
            return 'zztabletcol'

    @property
    def columns(self) -> str:
        """Return the columns field in the Latex environment header.

        """
        df = self.dataframe
        cols = 'l' * df.shape[1]
        cols = '|' + '|'.join(cols) + '|'
        return cols

    @property
    def params(self) -> Dict[str, str]:
        """Return the parameters used for creating the table.

        """
        return {'tabname': self.name,
                'latex_environment': self.latex_environment,
                'caption': self.caption,
                'columns': self.columns,
                'size': self.size}

    @property
    def header(self) -> str:
        """Return the Latex environment header.

        """
        return """\\begin{%(latex_environment)s}{%(tabname)s}%%
{%(caption)s}{\\%(size)s}{%(columns)s}""" % self.params

    @property
    @persisted('_dataframe')
    def dataframe(self) -> pd.DataFrame:
        """Return the pandas Dataframe that holds the CSV data.

        """
        return pd.read_csv(self.path)

    def __str__(self):
        return f'{self.name}: env={self.latex_environment}, size={self.size}'


class SlackTable(Table):
    """An instance of the table that fills up space based on the widest column.

    """
    def __init__(self, *args, slack_col=0, **kwargs):
        super(SlackTable, self).__init__(*args, **kwargs)
        self.slack_col = slack_col

    @property
    def latex_environment(self):
        return 'zzvarcoltable'

    @property
    def header(self):
        return """\\begin{%(latex_environment)s}[\\textwidth]{h}{%(tabname)s}{%(caption)s}%%
{\\%(size)s}{%(columns)s}""" % self.params

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

"""  % {'date': date, 'package_name': self.package_name})

    def _write_footer(self):
        pass

    def _write_table(self, table):
        writer = self.writer
        df = table.dataframe
        cols = [tuple(map(lambda c: f'\\textbf{{{c}}}', df.columns))]
        data = it.chain(cols, map(lambda x: x[1].tolist(), df.iterrows()))
        lines = tabulate(data, tablefmt='latex_raw', headers='firstrow').split('\n')
        writer.write('\n\\newcommand{\\%(tabname)s}{%%\n' % table.params)
        writer.write(table.header)
        writer.write('\n')
        for l in lines[1:-1]:
            writer.write(l + '\n')
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
                        format='mklatextbl: %(levelname)s: %(message)s')
    mng = TableFileManager(Path(table_path))
    logger.info(f'preparing package {mng.package_name}')
    with open(output_file, 'w') as f:
        tab = CsvToLatexTable(mng.tables, mng.package_name, f)
        tab.write()
    logger.info(f'wrote {output_file}')


if __name__ == '__main__':
    plac.call(write_latex_table)
