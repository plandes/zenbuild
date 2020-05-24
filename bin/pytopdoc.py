#!/usr/bin/env python

"""Create a top level Sphinx documentation .rst file.

"""
__author__ = 'Paul Landes'

import sys
import logging
import plac
import json
from pathlib import Path

logger = logging.getLogger()

DEBUG = True


@plac.annotations(
    build_info=('The path the build info file (probably target/build.json)',
                'positional', None, Path),
    template=('The input .rst template to use as a template', 'positional',
              None, Path),
    output=('The output file name.', 'positional', None, Path))
def main(build_info: Path, template: Path, output: Path):
    """Create a top level Sphinx documentation .rst file."""
    try:
        with open(build_info) as f:
            info = json.load(f)
        logger.info(f'using project root: {info["root_path"]}')
        long_desc = info['description']
        short_desc = info['short_description']
        with open(output, 'w') as writer:
            writer.write(short_desc + '\n')
            writer.write('=' * len(short_desc) + '\n')
            writer.write(long_desc + '\n\n')
            with open(template) as f:
                writer.write(f.read())
            logger.info(f'wrote template {template} to {output}')
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
