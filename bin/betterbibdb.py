#!/usr/bin/env python

from typing import Tuple, Any, Dict
from dataclasses import dataclass
from io import StringIO
import sys
import json
from sqlite3 import OperationalError
from zensols.config import ConfigurableError
from zensols.cli import ApplicationFactory as CliApplicationFactory
from zensols.cli import ApplicationError
from zensols.db import DbPersister


CONFIG = """
[cli]
class_name = zensols.cli.ActionCliManager
apps = list: config_cli, app

[config_cli]
class_name = zensols.cli.ConfigurationImporter

[sqlite_conn_manager]
class_name = zensols.db.SqliteConnectionManager
db_file = path: ${default:data_dir}/better-bibtex.sqlite

[import]
sections = list: imp_env

[imp_env]
type = environment
section_name = env
includes = set: HOME

[db_persister]
class_name = zensols.db.bean.DbPersister
conn_manager = instance: sqlite_conn_manager

[app]
class_name = betterbibdb.Application
sql = select data from 'better-bibtex' where name = 'better-bibtex.citekey'
persister = instance: db_persister
"""


@dataclass
class Application(object):
    """Map Zotero keys to BetterBibtex citekeys.

    """
    CLI_META = {'option_excludes': {'sql', 'persister'}}
    sql: str
    persister: DbPersister

    @property
    def database(self) -> Dict[str, Dict[str, Any]]:
        """Get all entries from the BetterBibtex database with <libraryID>_<itemKey> as
        keys and the dict entry as values.

        """
        res: Tuple[Tuple[str]] = self.persister.execute(self.sql)
        col_data = json.loads(res[0][0])
        db = col_data['data']
        return {f"{d['libraryID']}_{d['itemKey']}": d for d in db}

    def lookup(self, format: str = '{entry}', key: str = None):
        """Look up a citation key and print out BetterBibtex field(s).

        :param key: key in format <libraryID>_<itemKey>, standard input if not
                    given, or 'all'

        :param format: the format of the output, defaults to the entire entry

        """
        db = self.database
        if key is None:
            keys = map(lambda s: s.strip(), sys.stdin.readlines())
        else:
            keys = [key]
        if key == 'all':
            for key, entry in db.items():
                entry['entry'] = entry
                print(format.format(**entry))
        else:
            for key in keys:
                entry: Dict[str, Any] = dict(db[key])
                entry['entry'] = entry
                print(format.format(**entry))


class ApplicationFactory(CliApplicationFactory):
    def __init__(self, *args, **kwargs):
        super().__init__(
            package_resource='zensols.zotsite',
            app_config_resource=StringIO(CONFIG))

    def _handle_error(self, ex: Exception):
        if isinstance(ex, ConfigurableError):
            print("""
This configuration needs a 'default' section with option entry 'data_dir'
that points to the directory where the zotero SQLite files live.  The file can
be the same as the Zotsite configuration file and looks for the ZOTSITERC
environment variable.""", file=sys.stderr)
        elif isinstance(ex, OperationalError):
            ex = ApplicationError(f'Could not access Zotero DB: {ex}')
        elif isinstance(ex, BrokenPipeError):
            # don't print the broken pipe error when pipe programs like head
            sys.stderr.close()
            sys.exit(0)
        super()._handle_error(ex)


if (__name__ == '__main__'):
    cli = ApplicationFactory.create_harness()
    cli.run()
