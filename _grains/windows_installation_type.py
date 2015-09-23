# -*- coding: utf-8 -*-
from __future__ import absolute_import
import logging
from os import environ, path, sep
from re import match

log = logging.getLogger(__name__)

def windows_installation_type():
    ## A simple hack---"%windir%\explorer.exe" does not exist on
    ## Server Core.  This will need to be revised with the release of
    ## vNext Server, which adds a "Nano Server" install type.
    grains = {}
    if match('Microsoft Windows Server', __grains__['osfullname']):
        if path.isfile(sep.join([environ['windir'], "explorer.exe"])):
            grains['osinstalltype'] = 'Standard'
        else:
            grains['osinstalltype'] = 'Server Core'
    return grains
