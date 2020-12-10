from dataclasses import dataclass, field
import logging
import os

logger = logging.getLogger(__name__)


@dataclass
class Keychain(object):
    """A wrapper to macOS's Keychain service using binary ``/usr/bin/security``.
    This provides a cleartext password for the given service and account.

    :param service: the service (grouping in ``Keychain.app``)

    :param account: the account, which is usually an email address

    """
    account: str
    service: str = field(default='python-passwords')

    @staticmethod
    def getpassword(account: str, service: str) -> str:
        """Get the password for the account and service (see class docs).

        """
        cmd = (f'/usr/bin/security find-generic-password ' +
               f'-w -s {service} -a {account}')
        with os.popen(cmd) as p:
            s = p.read().strip()
        return s

    @property
    def password(self):
        """Get the password for the account and service provided as member variables
        (see class docs).

        """
        logger.debug(f'getting password for service={self.service}, ' +
                     f'account={self.account}')
        return self.getpassword(self.account, self.service)
