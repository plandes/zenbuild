#!/usr/bin/env python

"""Command line program to access build information.

"""
__author__ = 'Paul Landes'

from typing import List, Dict, Union, Iterable, Tuple
from dataclasses import dataclass, field
import logging
import re
import sys
import json
import plac
from pathlib import Path

logger = logging.getLogger(__name__)

DEBUG = False


@dataclass
class BuildInfoFetcher(object):
    """This class uses the project confgiuration and git metadata to output
    confgiuration useful for executing build.  The build information is created
    as a JSON file using ``SetupUtil`` and persisting it to disk for subsequent
    fast retrieval.

    :param path: points to somewhere in the temporary ``target`` directory

    :param format: indicates how to format the output

    :py:meth:`zensols.pybuild.SetupUtil`

    """
    DEFAULT_SETUP = Path('src/python/setup.py')
    ATTTR_REGEX = re.compile(r'^([^\[]+?)?(?:\[([0-9]+?)\])?$')
    KEY_REGEX = re.compile(r'\[([0-9]+?)\]_?')

    path: Path
    rel_setup_path: Path = field(default=DEFAULT_SETUP)
    format: str = field(default='val')
    exist_strict: bool = field(default=False)
    index_strict: bool = field(default=False)
    type_strict: bool = field(default=False)

    def _assert_build_info(self):
        """Create the build info JSON file by using ``SetupUtil`` instance's
        ``to_json`` method.

        :py:function:`zensols.pybuild.SetupUtil.to_json`

        """
        if not self.path.exists():
            from zensols.pybuild import SetupUtil
            self.path.parent.mkdir(parents=True, exist_ok=True)
            if not self.rel_setup_path.exists():
                raise OSError('configuration file does not ' +
                              f'exist: {self.rel_setup_path}')
            su = SetupUtil.source(rel_setup_path=self.rel_setup_path)
            logger.info(f'saving build info to {self.path}')
            with open(self.path, 'w') as f:
                su.to_json(writer=f)

    @property
    def build_info(self) -> Dict[str, Union[str, dict]]:
        """Return the build information tree of dicts.  If the JSON file of the data
        does not exist, then create it.

        :py:meth:`BuildInfoFetcher._assert_build_info`
        """
        self._assert_build_info()
        logger.info(f'loading build info from {self.path}')
        if not hasattr(self, '_build_info'):
            with open(self.path) as f:
                self._build_info = json.load(f)
        return self._build_info

    def _get_attrib_by_path(self, attrib_path: List[str], binfo: dict) -> \
            Union[str, dict]:
        """Recursively traverse the build information tree using path
        ``attrib_path``.  Return the data in tree, usually a string.

        """
        if len(attrib_path) > 0:
            name = attrib_path.pop(0)
            # single dot case
            if len(name) == 0:
                binfo = self._get_attrib_by_path(attrib_path, binfo)
            else:
                name, index = self.ATTTR_REGEX.match(name).groups()
                if name is not None:
                    binfo = binfo.get(name)
                if binfo is not None:
                    if index is not None:
                        index = int(index)
                        if index >= len(binfo):
                            if self.index_strict:
                                raise ValueError(f'no attriubte at index {index}')
                            else:
                                binfo = None
                        else:
                            binfo = binfo[index]
                    binfo = self._get_attrib_by_path(attrib_path, binfo)
        return binfo

    def _get_attrib(self, attrib_path: str, binfo: dict) -> str:
        """Return a value with dotted jq like path ``attrib_path`` for an attribute
        treating ``binfo`` as a tree data structure.

        """
        apath = attrib_path.split('.')
        return self._get_attrib_by_path(apath, binfo)

    def get_attribs(self, attribs: List[str]) -> Iterable[Tuple[str, str]]:
        """Return an iterable of attriubtes as (name, value) tuples.

        """
        binfo = self.build_info
        for attrib in attribs:
            try:
                val = self._get_attrib(attrib, binfo)
            except Exception as e:
                logger.error(f'could not get attribute {attrib}: {e}')
                raise e
            if self.type_strict and not isinstance(val, str):
                raise ValueError(f'wrong value found for attribute: {attrib}')
            if val is not None:
                yield ((attrib, val))
            elif self.exist_strict:
                raise ValueError(f'no such attribute: {attrib}')

    def get_attrib_dict(self, attribs: Tuple[str]) -> Dict[str, str]:
        """Return a set key attributes as a dict where keys are ``attribs``.

        :see: :meth:`get_attribs`

        """
        attrs = self.get_attribs(attribs)
        attrs = tuple(map(lambda a: (a[0][1:], a[1]), attrs))
        return dict(attrs)

    def _format_key(self, k: str) -> str:
        """Format a key from the dot path information.

        """
        if k[0] == '.':
            k = k[1:]
        k = k.replace('.', '_')
        k = k.upper()
        k = re.sub(self.KEY_REGEX, '', k)
        return k

    def __call__(self, attribs: List[str]):
        """Print out attribute ``attribs`` key values one per line.

        """
        fmt = self.format
        for k, v in self.get_attribs(attribs):
            if fmt == 'shell' or fmt == 'make':
                k = self._format_key(k)
                if fmt == 'shell':
                    v = f'export {k} = "{v}"'
                else:
                    v = f'{k} = {v}'
            print(v)


@plac.annotations(
    path=plac.Annotation('The path to the JSON build.json blob.', type=Path),
    strict=plac.Annotation('Be strict and exit on failures', 'flag', 's'),
    setup=plac.Annotation('The path to the setup.py file.', 'option', 'p',
                          type=Path),
    format=plac.Annotation('The format of the output',
                           'option', 'f', str, ['val', 'make', 'shell']),
    attribs=plac.Annotation('Path to the JSON data desired', type=str))
def main(path: Path, strict: bool,
         setup: Path = BuildInfoFetcher.DEFAULT_SETUP,
         format: str = 'val', *attribs: List[str]):
    """Access build information made available the git and setuptools metdaata.
This accesses uses ``zensols.pybuild.SetupUtil`` to access the git metadata
and``setup.py`` module metadata."""
    logger.info(f'parsing {path} using format {format}')
    try:
        fetcher = BuildInfoFetcher(path, setup, format, strict, strict, strict)
        fetcher(attribs)
    except Exception as e:
        if DEBUG:
            import traceback
            traceback.print_exc()
        logger.error(e)
        sys.exit(1)


if __name__ == '__main__':
    logging.basicConfig(
        level=logging.DEBUG if DEBUG else logging.WARNING,
        format='buildinfo: %(levelname)s: %(message)s')
    plac.call(main)
