'''
Manage AD Federation Services
=============================

Deploy and extend AD FS farms and federation proxies.

States may execute PowerShell cmdlets in a different security context
than the Salt minion by specifying Windows credentials (username and
password), whether by specifying them in the minion configuration:

.. code-block:: yaml

    adfs.username: 'EXAMPLE\username'
    adfs.password: 'P@55w0rd!!'

By specifying the ``username`` and ``password`` keyword arguments to a
state:

.. code-block:: yaml

    fsweb.example.com:
      farm.installed:
        - username: 'EXAMPLE\username'
        - password: 'P@55w0rd!!'

In a dictionary passed directly to the state:

.. code-block:: yaml

    fsweb.example.com:
      farm.installed:
        - credentials:
            username: 'EXAMPLE\username'
            password: 'P@55w0rd!!'

Or by referencing a dictionary stored in Pillar or the minion
configuration:

.. code-block:: yaml

    mycredentials:
      username: 'EXAMPLE\username'
      password: 'P@55w0rd!!'

.. code-block:: yaml

    fsweb.example.com:
      farm.installed:
        - credentials: mycredentials
'''

def __virtual__():
    return 'identityserver_sts' if 'identityserver_sts.get_adfsproperties' in __salt__ else False

def property(name, value, **kwargs):
    '''Set the named AD FS property to the specified value.

    :param name:
        the name of the AD FS property (e.g.,
        ``AutoCertificateRollover``)

    :param value:
        the desired value of the named AD FS property (e.g.,
        ``False``)
    '''
    ret = {'name': name,
           'result': True,
           'changes': {},
           'comment': ''}

    ## Determine whether the named property already has the specified
    ## value.
    properties = __salt__['identityserver_sts.get_adfsproperties']()
    if name not in properties:
        ret['result'] = False
        ret['comment'] = 'AD FS property {0} cannot be found'.format(name)
        return ret
    elif properties[name] == value:
        ret['comment'] = 'AD FS property {0} is already set to:\n\n{1}'.format(name, value)
        return ret
    else:
        ret['changes'] = {'identityserver_sts': 'AD FS property {0} changed from:\n\t{1}\n\nTo:\n\t{2}'.format(name, properties[name], value)}

    ## Test mode: Only report what would have happened.
    if __opts__['test']:
        ret['result'] = None
        return ret

    ## Update the value of the property.
    arglist = {name: value}
    __salt__['identityserver_sts.set_adfsproperties'](**arglist)
    ## TODO: check the return result

    return ret
