#!/usr/bin/env python

from typing import Dict, Sequence
from dataclasses import dataclass, field
from io import StringIO
import logging
import re
import applescript as aps
from zensols.persist import persisted
from zensols.config import ConfigFactory, Dictable
from zensols.cli import CliHarness, ApplicationError

logger = logging.getLogger(__name__)


CONFIG = """
[cli]
class_name = zensols.cli.ActionCliManager
apps = list: config_cli, log_cli, app

[config_cli]
class_name = zensols.cli.ConfigurationImporter
expect = False
type = import
section = config_import

[log_cli]
class_name = zensols.cli.LogConfigurator
log_name = showpreview
format = showpreview: %%(message)s
level = info

[config_import]
config_files = list: {config_path}

[screen_manager]
class_name = showpreview.ScreenManager

[app]
class_name = showpreview.Application
smng = instance: screen_manager
"""

SHOW_PREVIEW_FUNC = """
on showPreview(x, y, width, height)
    log "update preview"
    tell application "Preview"
         activate
         set theBounds to {x, y, width, height}
         set the bounds of the window 1 to theBounds
    end tell
    log "zoom reset via system events"
    tell application "System Events"
         tell process "Preview"
                 click menu item "Single Page" of menu "View" of menu bar 1
                 click menu item "Continuous Scroll" of menu "View" of menu bar 1
         end tell
    end tell
    tell application "Emacs" to activate
end showPreview
"""


@dataclass(eq=True, unsafe_hash=True)
class Size(Dictable):
    width: int
    height: int

    def __str__(self):
        return f'{self.width} X {self.height}'


@dataclass(eq=True, unsafe_hash=True)
class Display(Size):
    _DICTABLE_WRITE_EXCLUDES = {'name'}
    name: str
    target: Size

    def __str__(self):
        return super().__str__() + f' ({self.name})'


@dataclass
class ScreenManager(object):
    config_factory: ConfigFactory = field()
    display_names: Sequence[str] = field(default_factory=list)

    def _exec(self, cmd: str, app: str = None) -> str:
        ret: aps.Result
        if app is None:
            ret = aps.run(cmd)
        else:
            ret = aps.tell.app(app, cmd)
        if ret.code != 0:
            raise ApplicationError(
                f'Could not invoke <{cmd}>: {ret.err} ({ret.code})')
        return ret.out

    @property
    @persisted('_displays')
    def displays(self) -> Dict[str, Size]:
        def map_display(name: str) -> Display:
            targ = Size(**fac(f'{name}_target').asdict())
            return Display(**fac(name).asdict() |
                           {'name': name, 'target': targ})

        fac = self.config_factory
        return {d.name: d for d in map(map_display, self.display_names)}

    @property
    @persisted('_displays_by_size')
    def displays_by_size(self) -> Dict[Size, Display]:
        return {Size(d.width, d.height): d for d in self.displays.values()}

    @property
    def screen_size(self) -> Size:
        bstr: str = self._exec('bounds of window of desktop', 'Finder')
        bounds: Sequence[int] = tuple(map(int, re.split(r'\s*,\s*', bstr)))
        width, height = bounds[2:]
        return Size(width, height)

    def resize(self, size: Size):
        logger.info(f'resizing to {size}')
        cmd = (SHOW_PREVIEW_FUNC + '\n' +
               f'showPreview(0, 0, {size.width}, {size.height})')
        self._exec(cmd)

    def detect_and_resize(self):
        screen: Size = self.screen_size
        display: Display = self.displays_by_size.get(screen)
        logger.debug(f'screen size: {screen} -> {display}')
        if display is None:
            raise ApplicationError(f'No display entry for bounds: {screen}')
        logger.debug(f'detected display {display}')
        self.resize(display.target)


@dataclass
class Application(object):
    """Probe screen and set the preview applicatin extends.

    """
    CLI_META = {'option_excludes': {'smng'}}

    smng: ScreenManager = field()
    """Detects and controls the screen."""

    width: int = field(default=None)
    """The width to set."""

    height: int = field(default=None)
    """The height to set."""

    def config(self):
        """Print the display configurations."""
        for n, dsp in sorted(self.smng.displays.items(), key=lambda x: x[0]):
            print(f'{n}:')
            dsp.write(1)

    def resize(self):
        """Set the preview application frame location and size.  If the width and
        height are not given, it uses the (optional) configuration file values.

        """
        if self.width is None and self.height is None:
            self.smng.detect_and_resize()
        elif self.width is not None or self.height is not None:
            raise ApplicationError(
                'Both width and height are expected when either is given')
        else:
            self.smng.resize(Size(self.width, self.height))


if (__name__ == '__main__'):
    CliHarness(
        app_config_resource=StringIO(CONFIG),
        package_resource='showpreview',
    ).run()
