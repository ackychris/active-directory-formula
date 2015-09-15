def __virtual__():
    '''
    Load only if the windows_features module is loaded.
    '''
    return 'windows_feature' if 'windows_servicing.enable_feature' in __salt__ else False

def enabled(name,
            image=None,
            package=None,
            sources=[]):
    '''
    Install a Windows feature.
    '''
    ret = {'name': name,
           'result': True,
           'changes': {},
           'comment': ''}

    ## Determine whether the feature is already enabled.
    features = __salt__['windows_servicing.get_features'](image, package)
    if name not in features:
        ret['result'] = False
        ret['comment'] = 'The feature {0} cannot be found'.format(name)
        return ret
    elif features[name]['State'] == 'Enabled':
        ret['comment'] = 'The feature {0} is already installed'.format(name)
        return ret
    elif features[name]['State'] == 'Enable Pending':
        ret['comment'] = 'The feature {0} is already installed (pending a reboot)'.format(name)
        return ret
    else:
        ret['changes'] = {'windows_feature': 'The feature {0} will be installed'.format(name)}

    ## Test mode: Only report what would have happened.
    if __opts__['test']:
        ret['result'] = None
        return ret

    ## Enable the feature.
    if __salt__['windows_servicing.enable_feature'](name, image, package, sources)['result']:
        ret['changes'] = {'windows_feature': 'Installed {0}'.format(name)}
    else:
        ret['result'] = False
        ret['comment'] = 'Failed to install {0}'.format(name)
    return ret

def disabled(name,
             image=None,
             keep_manifest=False):
    '''
    Remove a Windows feature.
    '''
    ret = {'name': name,
           'result': True,
           'changes': {},
           'comment': ''}

    ## Determine whether the feature is already disabled.
    features = __salt__['windows_servicing.get_features'](image)
    if name not in features:
        ret['result'] = False
        ret['comment'] = 'The feature {0} cannot be found'.format(name)
        return ret
    elif features[name]['State'] == 'Disabled':
        ret['comment'] = 'The feature {0} is already removed'.format(name)
        return ret
    elif features[name]['State'] == 'Disable Pending':
        ret['comment'] = 'The feature {0} is already removed (pending a reboot)'.format(name)
        return ret
    else:
        ret['changes'] = {'windows_feature': 'The feature {0} will be removed'.format(name)}

    ## Test mode: Only report what would have happened.
    if __opts__['test']:
        ret['result'] = None
        return ret

    ## Disable the feature.
    if __salt__['windows_servicing.disable_feature'](name, image, keep_manifest)['result']:
        ret['changes'] = {'Windows_feature': 'Removed {0}'.format(name)}
    else:
        ret['result'] = False
        ret['comment'] = 'Failed to remove {0}'.format(name)
    return ret
