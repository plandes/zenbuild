#!/usr/bin/env python

from typing import List, Set
from dataclasses import dataclass
import logging
from pathlib import Path
import re
import plac

logger = logging.getLogger(__name__)


@dataclass
class Cleaner(object):
    """Base class removes superfluous files on export.

    """
    export_dir: Path
    extensions: Set[str]
    keeps: Set[str]
    dry_run: bool

    def _get_input_files(self) -> Set[Path]:
        paths = []
        for ext in self.extensions:
            files = self.export_dir.glob(f'*.{ext}')
            paths.extend(files)
        return set(paths)

    def _parse_file_names(self, paths: List[Path]) -> List[str]:
        fnames = []
        for path in paths:
            logger.debug(f'parsing: {path}')
            with open(path) as f:
                for line in map(lambda ln: ln.strip(), f.readlines()):
                    m = None
                    for regex in self._INCUDE_REGEX:
                        m = regex.match(line)
                        if m is not None:
                            break
                    if m is not None:
                        parts = m.groups()
                        if len(parts) == 1:
                            fname = m.group(1) + '.' + self._ADD_EXT
                        else:
                            fname = '.'.join(m.groups())
                        logger.debug(f'parsed keep file: {fname}')
                        fnames.append(path.parent / fname)
        return fnames

    def __call__(self):
        keeps = self._parse_file_names(self._get_input_files())
        keeps = set(map(lambda p: p.name, keeps))
        keeps |= self.keeps
        rms = filter(lambda p: self._DEL_REGEX.match(p.name) is not None,
                     self.export_dir.iterdir())
        for path in rms:
            if path.name in keeps:
                logger.info(f'matched file, but keeping: {path}')
            else:
                logger.info(f'deleting file: {path}')
                if not self.dry_run:
                    path.unlink()


@dataclass
class ImageCleaner(Cleaner):
    """Remove image files generated, but not included in the final latex file.

    """
    _INCUDE_REGEX = tuple(
        map(re.compile,
            # leave off end for multi-line titles
            [r'^\\zzfigure(?:tcp)?\{.*\}\{(.+)\}\{.*$',
             r'^\\zzfiguretc(?:\[.+\])\{(.+)\}\{.*$',
             r'^\\zzfigurerast(?:tc)?\{.*\}\{(.+)\}\{(.+)\}\{.*$',
             r'^\\zzfigurerasttcp(?:tc)?\{.*\}\{.*\}\{(.+)\}\{(.+)\}\{.*$',
             ]))
    _DEL_REGEX = re.compile(r'.*(' + '|'.join('eps png jpg gif'.split()) + ')$')
    _ADD_EXT = 'eps'


@dataclass
class StyleCleaner(Cleaner):
    """Remove unused .sty files, usually from zenbuild sty library.

    """
    _INCUDE_REGEX = (re.compile(r'^\s*\\usepackage(?:\[.+\])?\{(.+)\}.*'),)
    _DEL_REGEX = re.compile(r'.*(' + '|'.join('sty'.split()) + ')$')
    _ADD_EXT = 'sty'

    def _parse_file_names(self, paths: List[Path]) -> Set[str]:
        keeps = set()
        while True:
            paths = super()._parse_file_names(paths)
            paths = tuple(filter(lambda p: p.is_file() and p not in keeps,
                                 paths))
            if len(paths) == 0:
                break
            keeps.update(paths)
        return keeps


@plac.annotations(
    exportdir=('The directory to remove extra files.', 'positional',
               None, Path),
    keeps=('File separated list of files to skip deletion.', 'option',
           None, str),
    dryrun=('Don\'t do anything, just act like it.', 'flag'))
def main(exportdir: Path, keeps: str = None, dryrun: bool = False):
    logging.basicConfig(level=logging.INFO,
                        format='cleaneps.py: %(levelname)s: %(message)s')
    keeps = keeps.split(',') if keeps is not None else ()
    keeps = set(keeps)
    exts = {'tex', 'sty'}
    cleaners = [
        ImageCleaner(exportdir, exts, keeps, dryrun),
        StyleCleaner(exportdir, exts, keeps, dryrun),
    ]
    for cleaner in cleaners:
        cleaner()


if (__name__ == '__main__'):
    plac.call(main)
