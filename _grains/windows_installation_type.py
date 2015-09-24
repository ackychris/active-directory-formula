# -*- coding: utf-8 -*-
from __future__ import absolute_import
import logging
import os
import re
import salt.utils

log = logging.getLogger(__name__)

HAS_WMI = False
if salt.utils.is_windows():
    try:
        import wmi
        import salt.utils.winapi
        HAS_WMI = True
    except ImportError:
        log.exception('Unable to import Python wmi module; the osinstalltype grain will be missing.')

def windows_installation_type():
    if not HAS_WMI:
        return {}

    with salt.utils.winapi.Com():
        wmi_c = wmi.WMI()
        osinfo = wmi_c.Win32_OperatingSystem()[0]
        (osfullname, _) = osinfo.Name.split('|', 1)
        osfullname = osfullname.strip()

    ## A simple hack---"%windir%\explorer.exe" does not exist on
    ## Server Core.  This will need to be revised with the release of
    ## vNext Server, which adds a "Nano Server" install type.
    grains = {}
    if re.match('Microsoft Windows Server', osfullname):
        if os.path.isfile(
                os.sep.join(
                    [os.environ['windir'],
                     "explorer.exe"])):
            grains['osinstalltype'] = 'Standard'
        else:
            grains['osinstalltype'] = 'Server Core'
    return grains
