#!/usr/bin/env python

"""Utility to create conda lock files.

"""
__author__ = 'Paul Landes'

from typing import Dict, List, Any
from dataclasses import dataclass, field
import logging
import sys
from pathlib import Path
import json
import yaml
import subprocess as proc
import plac
from zensols.config import Dictable
from zensols.pybuild import SetupUtil

logger = logging.getLogger('repoutil')


class Dumper(yaml.Dumper):
    def increase_indent(self, flow=False, indentless=False):
        return super(Dumper, self).increase_indent(flow, False)


@dataclass
class CondaEnvironmentLocker(Dictable):
    in_path: Path = field()
    output_file: Path = field()
    repo_path: Path = field(default=Path('.'))
    dry_run: bool = field(default=False)

    def _add_repo_spec(self, env: Dict[str, Any]) -> Dict[str, Any]:
        su = SetupUtil.source(start_path=self.repo_path)
        name: str = su.project
        env['name'] = name
        env['prefix'] = 'env'
        for dep in env['dependencies']:
            if isinstance(dep, dict) and 'pip' in dep:
                pip: List[str] = dep['pip']
                pip.append(f'{su.name}=={su.tag.last_tag}')
        return env

    def _export_env(self) -> Dict[str, Any]:
        output: str = proc.check_output(
            args=f'conda env export --in_path {self.in_path} --json'.split(),
            text=True)
        return json.loads(output)

    def _write_env(self, env: Dict[str, Any]):
        with open(self.output_file, 'w') as f:
            yaml.dump(
                env,
                stream=f,
                Dumper=Dumper,
                default_flow_style=False)
        logger.info(f'wrote: {self.output_file}')

    def convert(self):
        with open(self. in_path) as f:
            env: Dict[str, Any] = yaml.load(f, yaml.FullLoader)
        env = self._add_repo_spec(env)
        self._write_env(env)
        if 1:
            with open(self.output_file) as f:
                print(f.read())

    def export(self):
        env: Dict[str, Any] = self._export_env()
        env = self._add_repo_spec(env)
        self._write_env(env)


@plac.annotations(
    action=('<convert|export>', 'positional', None, str),
    path=('<prefix|environment file>', 'option', 'i', Path),
    out=('the environment file', 'option', 'o', Path),
    dryrun=('don\'t do anything, just act like it', 'flag', 'd'))
def main(action: str, path: Path = Path('src/python/environment.yml'),
         out: Path = Path('environment.yml'),
         dryrun: bool = False):
    """
    Create an environment.yml file with the application requirements or export
    it from an existing environment by prefix.
    """
    logging.basicConfig(level=logging.WARNING, format='%(message)s')
    logger.setLevel(level=logging.INFO)
    params: Dict[str, str] = {
        'in_path': path.expanduser(),
        'output_file': out,
        'dry_run': dryrun}
    ru = CondaEnvironmentLocker(**params)
    try:
        getattr(ru, action)()
    except AttributeError as e:
        print(f'no such action: {action}: {e}', file=sys.stderr)
        sys.exit(1)


if (__name__ == '__main__'):
    plac.call(main)
