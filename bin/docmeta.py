#!/usr/bin/env python

"""Create a document API index to the document server.

"""
__author__ = 'Paul Landes'

from typing import Dict
from dataclasses import dataclass
import sys
import logging
import json
import plac
from pathlib import Path
from buildinfo import BuildInfoFetcher

logger = logging.getLogger()

DEBUG = False


@dataclass
class DocMetadataAPI(object):
    """Manage the document API metadata.

    :param fetcher: used to get the build information about the documents being
                    copied

    """
    fetcher: BuildInfoFetcher
    meta_path: Path

    @property
    def meta(self) -> Dict[str, str]:
        logger.info(f'loading metadata from {self.meta_path}')
        if self.meta_path.exists():
            with open(self.meta_path) as f:
                return json.load(f)
        else:
            return {}

    @property
    def attributes(self) -> Dict[str, str]:
        logger.debug(f'loading attributes')
        attrs = '.project .build.tag .description .short_description'.split()
        attrs = self.fetcher.get_attribs(attrs)
        attrs = tuple(map(lambda a: (a[0][1:], a[1]), attrs))
        return dict(attrs)

    def save(self) -> Dict[str, str]:
        attrs = self.attributes
        meta = self.meta
        meta[attrs['project']] = attrs
        logger.info(f'saving metadata to {self.meta_path}')
        with open(self.meta_path, 'w') as f:
            json.dump(meta, f, indent=4)
        return meta


@plac.annotations(
    binfo=plac.Annotation('The path to the JSON build.json blob.', type=Path),
    meta=plac.Annotation('The path to the doc metadata blob.', type=Path))
def main(binfo: Path, meta: Path):
    """Create a document API index at the root of the API docroot."""
    try:
        fetcher = BuildInfoFetcher(binfo)
        meta = DocMetadataAPI(fetcher, meta)
        meta.save()
    except Exception as e:
        if DEBUG:
            import traceback
            traceback.print_exc()
        logger.error(e)
        sys.exit(1)


if __name__ == '__main__':
    logging.basicConfig(
        level=logging.DEBUG if DEBUG else logging.INFO,
        format='docmeta.py: %(levelname)s: %(message)s')
    plac.call(main)
