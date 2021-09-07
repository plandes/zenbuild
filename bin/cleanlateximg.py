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
    # leave off end for multi-line titles
    _INCUDE_REGEX = tuple(
        map(re.compile,
            [r'^\\zzfigure\{.*\}\{(.+)\}\{.*$',
             r'^\\zzfiguretc(?:\[.+\])\{(.+)\}\{.*$',
             r'^\\zzfigurerast(?:tc)?\{.*\}\{(.+)\}\{(.+)\}\{.*$']))
    _DEL_REGEX = re.compile(r'.*(' + '|'.join('eps png jpg gif'.split()) + ')$')
    tex_file: Path
    export_dir: Path
    keeps: Set[str]

    def _parse_file_names(self) -> List[str]:
        fnames = []
        with open(self.tex_file) as f:
            for line in map(lambda ln: ln.strip(), f.readlines()):
                m = None
                for regex in self._INCUDE_REGEX:
                    m = regex.match(line)
                    if m is not None:
                        break
                if m is not None:
                    parts = m.groups()
                    if len(parts) == 1:
                        fname = m.group(1) + '.eps'
                    else:
                        fname = '.'.join(m.groups())
                    logger.debug(f'parsed keep file: {fname}')
                    fnames.append(fname)
        return fnames

    def __call__(self):
        keeps = set(self._parse_file_names()) | self.keeps
        rms = filter(lambda p: self._DEL_REGEX.match(p.name) is not None,
                     self.export_dir.iterdir())
        for path in rms:
            if path.name in keeps:
                logger.info(f'matched file, but keeping: {path}')
            else:
                logger.info(f'deleting file: {path}')
                path.unlink()


@plac.annotations(
    texfile=('The path to the Latex file', 'positional', None, Path),
    exportdir=('The directory to remove extra files.', 'positional',
               None, Path),
    keeps=('File separated list of files to skip deletion.', 'option',
           None, str),
    dryrun=('Don\'t do anything, just act like it.', 'flag'))
def main(texfile: Path, exportdir: Path,
         keeps: str = None, dryrun: bool = False):
    logging.basicConfig(level=logging.INFO,
                        format='cleaneps.py: %(levelname)s: %(message)s')
    keeps = keeps.split(',') if keeps is not None else ()
    cleaner = Cleaner(texfile, exportdir, set(keeps))
    cleaner()


if (__name__ == '__main__'):
    plac.call(main)
