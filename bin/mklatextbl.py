#!/usr/bin/env python3

import sys
import logging
import json
import yaml
import re
from pathlib import Path
from datetime import datetime
from tabulate import tabulate
import itertools as it
import plac
import pandas as pd
from zensols.actioncli import persisted

logger = logging.getLogger(__name__)


class Table(object):
    def __init__(self, path, name, caption, size='normalsize'):
        """Initialize a table.

        :param path: the path to the CSV file to make a latex table
        :param name: the name of the table, also used as the label
        :param caption: the human readable string used to the caption in the table

        :param size: the size of the table, and one of:
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
        self.path = path
        self.name = name
        self.caption = caption
        self.size = size

    @property
    def latex_environment(self):
        return 'zztabletcol'

    @property
    def columns(self):
        df = self.dataframe
        cols = 'l' * df.shape[1]
        cols = '|' + '|'.join(cols) + '|'
        return cols

    @property
    def params(self):
        return {'tabname': self.name,
                'latex_environment': self.latex_environment,
                'caption': self.caption,
                'columns': self.columns,
                'size': self.size}

    @property
    def header(self):
        return """\\begin{%(latex_environment)s}{%(tabname)s}%%
{%(caption)s}{\\%(size)s}{%(columns)s}""" % self.params

    @property
    @persisted('_dataframe')
    def dataframe(self):
        return pd.read_csv(self.path)

    def __str__(self):
        return f'{self.name}: env={self.latex_environment}, size={self.size}'


class SlackTable(Table):
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
    def __init__(self, tables: (list, Table), package_name: str,
                 writer=sys.stdout):
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
        data = it.chain([df.columns], map(lambda x: x[1].tolist(), df.iterrows()))
        lines = tabulate(data, tablefmt='latex_raw', headers='firstrow').split('\n')
        writer.write('\n\\newcommand{\\%(tabname)s}{%%\n' % table.params)
        writer.write(table.header)
        writer.write('\n')
        for l in lines[1:-1]:
            writer.write(l + '\n')
        writer.write('\\end{%s}}\n' % table.latex_environment)

    def write(self):
        self._write_header()
        for table in self.tables:
            self._write_table(table)
        self._write_footer()


class TableFileManager(object):
    FILE_NAME_REGEX = re.compile(r'(.+)\.yml')
    PACKAGE_FORMAT = '{name}'

    def __init__(self, table_path: Path):
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
