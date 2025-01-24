#!/usr/bin/env python

from typing import Tuple, Optional, ClassVar
from dataclasses import dataclass, field
from datetime import datetime
import logging
import sys
import re
from pathlib import Path
import plac

logger = logging.getLogger(__name__)


@dataclass
class Entry(object):
    version: str = field()
    date: str = field()

    def __str__(self) -> str:
        return f'{self.version} [{self.date}]'

    def __repr__(self) -> str:
        return self.__str__()


@dataclass
class ChangeLogParser(object):
    _ENTRY_REGEX: ClassVar[re.Pattern] = re.compile(
        r'^## \[(.+)\] - ([0-9-]+)$')
    path: Path = field()

    @property
    def today_str(self) -> str:
        now = datetime.now()
        return now.strftime('%Y-%m-%d')

    def __call__(self, date: str = None):
        def map_entry(s: str) -> Optional[str]:
            m: re.Match = self._ENTRY_REGEX.match(s)
            if m is not None:
                return Entry(*m.groups())

        date: str = self.today_str if date is None else date
        logger.debug(f"parsing '{self.path}' for date '{date}'")
        with open(self.path) as f:
            entries: Tuple[str, ...] = tuple(filter(
                lambda e: e is not None,
                map(map_entry, f.readlines())))
        date_entries: Tuple[Entry, ...] = tuple(filter(
            lambda e: e.date == date, entries))
        if len(date_entries) != 1:
            estr: str = ', '.join(map(str, date_entries))
            raise ValueError(f"Expecting one entry with date {date} but " +
                             f"got {len(date_entries)}: {estr}")
        return date_entries[0]


@plac.annotations(path=('the changelog file', 'positional', None, Path))
def parse_changelog(path: Path = Path('CHANGELOG.md')):
    parser = ChangeLogParser(path)
    try:
        today_entry = parser()
        print(f'v{today_entry.version}')
    except Exception as e:
        print(f'{prog}: error: {e}', file=sys.stderr)
        sys.exit(1)


if (__name__ == '__main__'):
    prog = Path(sys.argv[0]).name
    logging.basicConfig(format=f'{prog}: %(message)s', level=logging.WARNING)
    logger.setLevel(logging.INFO)
    plac.call(parse_changelog)
