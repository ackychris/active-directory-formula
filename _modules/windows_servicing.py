from __future__ import absolute_import
import logging
import re

import salt.utils

log = logging.getLogger(__name__)

def __virtual__():
    '''
    Load only on Windows Vista/Windows Server 2008 and newer.
    '''
    if __grains__['kernel'] == 'Windows' and int(__grains__['osversion'].split('.')[0]) >= 6:
        return 'windows_servicing'
    else:
        return False

def _dism(action, image=None):
    '''
    Run a DISM servicing command on the given image.
    '''
    command='dism {0} {1}'.format(
        '/Image:{0}'.format(image) if image else '/Online',
        action
    )
    return __salt__['cmd.run'](command, ignore_retcode=True)

def get_packages(image=None):
    '''
    Return information about all packages in the image.
    '''
    output = _dism('/Get-Packages', image)
    if not re.search('The operation completed successfully.', output):
        return {}

    return {p: {'State': s, 'Release Type': r, 'Install Time': t}
            for p, s, r, t
            in re.findall('Package Identity : ([^\r\n]+)\r?\nState : ([^\r\n]+)\r?\nRelease Type : ([^\r\n]+)\r?\nInstall Time : ([^\r?\n]+)\r?\n',
                          output, re.MULTILINE)}

def get_features(package=None, image=None):
    '''
    Return information about all features found in a specific package.  If
    you do not specify a package name or path, all features in the image
    will be listed.
    '''
    if package:
        output = _dism('/Get-Features /PackageName:{0}'.format(package), image)
    else:
        output = _dism('/Get-Features', image)
    if not re.search('The operation completed successfully.', output):
        return {}

    return {f: {'State': s}
            for f, s
            in re.findall('Feature Name : ([^\r\n]+)\r?\nState : ([^\r\n]+)\r?\n',
                          output, re.MULTILINE)}

def enable_feature(name, package=None, image=None):
    ret = {'name': name,
           'result': True,
           'changes': {},
           'comment': '',
           'dism': ''}
    features = get_features(package, image)
    if name not in features:
        ret['result'] = False
        ret['comment'] = 'Feature {0} not found'.format(name)
        return ret
    elif features[name]['State'] == 'Enabled':
        ret['comment'] = 'Feature {0} already installed'.format(name)
        return ret
    elif features[name]['State'] == 'Enable Pending':
        ret['comment'] = 'Feature {0} already installed (pending a reboot)'.format(name)
        return ret

    if package:
        output = _dism('/Enable-Feature /FeatureName:{0} /PackageName:{1} /NoRestart'.format(name, package))
    else:
        output = _dism('/Enable-Feature /FeatureName:{0} /NoRestart'.format(name))
    if not re.search('The operation completed successfully.', output):
        ret['result'] = False
        ret['comment'] = 'Feature {0} installation failed'.format(name)
        ret['dism'] = output
        return ret

    ret['changes'] = {'windows_servicing': 'Installed feature {0}'.format(name)}
    features = get_features(package, image)
    if features[name]['State'] == 'Enable Pending':
        ret['comment'] = 'Reboot to complete feature {0} installation'.format(name)
    return ret
