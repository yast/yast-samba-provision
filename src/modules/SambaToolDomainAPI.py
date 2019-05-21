from io import StringIO
from yast import ycpbuiltins
import sys

class YaSTIO(StringIO):
    def __init__(self, outf):
        super(YaSTIO, self).__init__()
        self.outf = outf

    def write(self, s):
        super(YaSTIO, self).write(s)
        self.outf(s)

from samba.netcmd import domain as dm
from samba.getopt import SambaOptions, CredentialsOptions
from samba.logger import get_samba_logger
from optparse import OptionParser
from samba.netcmd import CommandError
from yast import Declare

@Declare('string', 'string', 'string', 'string', 'string', 'string', 'boolean')
def provision(realm, domain, adminpass, function_level, dns_backend, use_rfc2307):
    '''Provision a domain
    param string realm          The realm name
    param string domain         NetBIOS domain name to use
    param string adminpass      Choose an admin password
    param string function_level The domain and forest function level (2000 | 2003 | 2008 | 2008_R2)
    param string dns_backend    The DNS server backend
    param boolean use_rfc2307   Use AD to store posix attributes
    return string               Error message, or an empty string
    '''
    parser = OptionParser()
    sambaopts = SambaOptions(parser)
    lp = sambaopts.get_loadparm()
    lp.set('realm', realm)

    outlog = YaSTIO(ycpbuiltins.y2debug)
    errlog = YaSTIO(ycpbuiltins.y2error)

    provision = dm.cmd_domain_provision(errf=errlog)
    provision.raw_argv = []
    provision.logger = get_samba_logger(name="provision",
                                        stream=outlog,
                                        verbose=True,
                                        quiet=False,
                                        fmt="%(message)s")

    try:
        provision.run(sambaopts=sambaopts,
                      domain=domain,
                      adminpass=adminpass,
                      function_level=function_level,
                      dns_backend=dns_backend,
                      server_role="dc")
    except CommandError as e:
        return [False, e.message]
    return [True, outlog.getvalue()]

@Declare('string', 'string', 'string', 'string', 'string', 'string')
def join(domain, role, dns_backend, username, password):
    '''Join domain as either member or backup domain controller
    param string domain         NetBIOS domain name to use
    param string role           possible values: MEMBER, DC, RODC, SUBDOMAIN
    param string dns_backend    The DNS server backend
    param string username       Username
    param string password       Password
    return string               Error message, or an empty string
    '''
    parser = OptionParser()
    sambaopts = SambaOptions(parser)
    credopts = CredentialsOptions(parser)
    credopts.creds.parse_string(username)
    credopts.creds.set_password(password)
    credopts.ask_for_password = False
    credopts.machine_pass = False

    outlog = YaSTIO(ycpbuiltins.y2debug)
    errlog = YaSTIO(ycpbuiltins.y2error)

    join = dm.cmd_domain_join(errf=errlog)
    join.logger = get_samba_logger(name="provision",
                                   stream=outlog,
                                   verbose=True,
                                   quiet=False,
                                   fmt="%(message)s")

    try:
        join.run(sambaopts=sambaopts,
                 credopts=credopts,
                 domain=domain,
                 role=role,
                 dns_backend=dns_backend)
    except CommandError as e:
        return [False, e.message]
    return [True, outlog.getvalue()]
