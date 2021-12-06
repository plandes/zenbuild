#!/usr/bin/env python

"""Create a top level Sphinx documentation .rst file.

"""
__author__ = 'Paul Landes'

from typing import Dict, Tuple
from dataclasses import dataclass, field
import sys
import logging
import re
from itertools import chain
import json
import shutil
import plac
from pathlib import Path
from buildinfo import BuildInfoFetcher
from zensols.config.keychain import Keychain

logger = logging.getLogger()

DEBUG = False


@dataclass
class DocConfigurer(object):
    PACKAGE_REGEX = re.compile(r'^([^.]+)\..+$')
    URL_REGEX = re.compile(r'^(https?)://(.+)$')
    INTERSPHINX_DEFAULTS = {
        'python': [
            ['python', 'https://docs.python.org/3']],
        'numpy': [
            ['numpy', 'https://numpy.org/doc/stable/']],
        'sklearn': [
            ['sklearn', 'http://scikit-learn.org/stable']],
        'pandas': [
            ['pandas', 'https://pandas.pydata.org/pandas-docs/stable']],
        'torch': [
            ['torch', 'https://pytorch.org/docs/master/']],
        'zensols.util': [
            ['zensols.util', '{url}/util/'],
            ['zensols.persist', '{url}/util/'],
            ['zensols.config', '{url}/util/'],
            ['zensols.cli', '{url}/util/'],
            ['zensols.multi', '{url}/util/']],
        'zensols.nlp': [
            ['zensols.nlp', '{url}/nlparse/']],
    }
    INTERSPHINX_DEFAULT_INCLUDES = ['python']

    fetcher: BuildInfoFetcher
    project_source_dir: Path
    template_source_dir: Path
    dest_dir: Path
    intersphinx_url: str = field(default='https://{user}.github.io')
    link_doc_root: str = field(default='https://github.com/{user}')
    user: str = field(default=None)
    conf_file_name: str = field(default='conf.json')
    top_rst: str = field(default='top.rst')
    rsts: Tuple[str] = field(default=('api.rst',))

    def __post_init__(self):
        self.link_doc_root += '/{project}/tree/master/doc'
        if self.user is not None:
            m = self.URL_REGEX.match(self.intersphinx_url)
            if m is None:
                raise ValueError(f'URL not valid: {self.intersphinx_url}')
            proto, server_path = m.groups()
            passwd = Keychain(self.user).password
            self.intersphinx_url = f'{proto}://{self.user}:{passwd}@{server_path}'

    @property
    def attributes(self) -> Dict[str, str]:
        if not hasattr(self, '_attr'):
            logger.debug('loading attributes')
            attrs = '.root_path .project .author .build.tag .url .name .user .description .short_description'.split()
            attrs = self.fetcher.get_attrib_dict(attrs)
            pmatch = self.PACKAGE_REGEX.match(attrs['name'])
            if pmatch:
                name = pmatch.group(1)
            else:
                name = attrs['name']
            attrs['package'] = name
            self._attr = attrs
        return self._attr

    def _get_config_path(self, name: str) -> Path:
        path = self.project_source_dir / name
        if not path.exists():
            path = self.template_source_dir / name
        if not path.exists():
            raise OSError(f'doc config file file not found: {name}')
        return path

    def write_desc_template(self):
        fname = self.top_rst
        short_desc = self.attributes['short_description']
        long_desc = self.attributes['description']
        src = self._get_config_path(fname)
        dst = self.dest_dir / fname
        with open(dst, 'w') as writer:
            writer.write(short_desc + '\n')
            writer.write('=' * len(short_desc) + '\n')
            writer.write(long_desc + '\n\n')
            with open(src) as f:
                writer.write(f.read())
            logger.info(f'wrote description RST {src} -> {dst}')

    def copy_rsts(self):
        for src_rst in self.rsts:
            src = self._get_config_path(src_rst)
            dst = self.dest_dir / src_rst
            logger.info(f'copying {src} -> {dst}')
            shutil.copy(src, dst)

    def _get_intersphinx_mapping(self) -> str:
        def fmt_entry(name, url_pat):
            url = self.intersphinx_url.format(**attribs)
            url = url_pat.format(**{'url': url})
            return f"'{name}': ('{url}', None)"

        attribs = self.attributes
        defs = dict(self.INTERSPHINX_DEFAULTS)
        adds = list(self.INTERSPHINX_DEFAULT_INCLUDES)
        conf_path = self._get_config_path(self.conf_file_name)
        if not conf_path.exists():
            logger.warning(f'missing document config file: {conf_path}' +
                           '--skippping intersphinx config')
        else:
            with open(conf_path) as f:
                conf = json.load(f)
            includes = conf['includes']
            named, mapped = includes['named'], includes['mapped']
            defs['mapped'] = mapped
            adds.extend(named)
            adds.append('mapped')
        smaps = map(lambda m: fmt_entry(*m),
                    chain.from_iterable(map(lambda d: defs[d], adds)))
        smaps = ',\n'.join(map(lambda s: f'    {s}', smaps))
        smaps = 'intersphinx_mapping = {\n' + smaps + '\n}'
        return smaps

    def write_conf_template(self, fname: str):
        attribs = dict(self.attributes)
        attribs['intersphinx_mapping'] = self._get_intersphinx_mapping()
        attribs['link_doc_root_url'] = self.link_doc_root.format(**attribs)
        src = self._get_config_path(fname)
        dst = self.dest_dir / fname
        lno = 0
        line = None
        try:
            with open(src) as fin:
                with open(dst, 'w') as fout:
                    for line in fin.readlines():
                        lno += 1
                        line = (line % attribs)
                        fout.write(line)
        except Exception as e:
            logger.error(f'bad template input line on {lno}: ' + line)
            raise e
        logger.info(f'wrote template {src} -> {dst}')

    def __call__(self):
        root_path = self.attributes['root_path']
        logger.info(f'using project root: {root_path}')
        self.copy_rsts()
        self.write_desc_template()
        self.write_conf_template('conf.py')


@plac.annotations(
    binfo=('The path the build info file (target/build.json)',
           'positional', None, Path),
    projsrcdir=('The project input doc configuration directory (src/doc)',
                'positional', None, Path),
    templatesrc=('The template directory (zenbuild/src/template/python/doc)',
                 'positional', None, Path),
    dstdir=('The destination directory.', 'positional', None, Path),
    url=('The URL for external documentation linking', 'option', 'u', str),
    user=('The login user for intersphinx webserver access', 'option', 'a', str))
def main(binfo: Path, projsrcdir: Path, templatesrc: Path,
         dstdir: Path, url: str = None, user: str = None):
    """Create a top level Sphinx documentation .rst file."""
    try:
        fetcher = BuildInfoFetcher(binfo)
        if url is not None:
            configurer = DocConfigurer(fetcher, projsrcdir, templatesrc,
                                       dstdir, url, url, user)
        else:
            configurer = DocConfigurer(fetcher, projsrcdir, templatesrc, dstdir)
        configurer()
    except Exception as e:
        if DEBUG:
            import traceback
            traceback.print_exc()
        logger.error(e)
        sys.exit(1)


if __name__ == '__main__':
    logging.basicConfig(
        level=logging.DEBUG if DEBUG else logging.INFO,
        format='pytopdoc.py: %(levelname)s: %(message)s')
    plac.call(main)
