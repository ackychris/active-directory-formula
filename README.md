# active-directory-formula

This repository contains a Salt state formula for Active Directory,
Microsoft's proprietary directory service.  The repository currently
consists of the following state modules:

* `ad.ds.forest`, which promotes the first domain controller in a new
  Active Directory forest;

* `ad.ds.tree` (for Windows Server 2008 R2 and older), which promotes
  the first domain controller in a new domain tree on an existing AD
  forest;

* `ad.ds.child` (for Windows Server 2008 R2 and older), which promotes
  the first domain controller in a new child domain of an existing AD
  tree;

* `ad.ds.domain` (for Windows Server 2012 and newer), which promotes
  the first domain controller in a new domain (tree or child) of an
  existing AD forest;

* `ad.ds.dc`, which promotes an additional writable domain controller
  in an existing AD domain;

* `ad.ds.rodc`, which creates a read-only domain controller account
  and then promotes a read-only DC in an existing domain;

* `w32time`, which can configure an authoritative time server on
  targeted computers; and

* `wins`, which installs a NetBIOS name server and configures full
  mesh, push/pull replication with its partners.

Refer to
[Salt Formulas - Installation](https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html#installation)
in the [SaltStack documentation](https://docs.saltstack.com/) for
installation instructions.  The author recommends forking this
repository and adding the fork to the Salt master via
[GitFS](https://docs.saltstack.com/en/latest/topics/tutorials/gitfs.html)
or [salt-formula](https://github.com/saltstack-formulas/salt-formula).
