# omsa

Installs and configures Dell OpenManage Server Administrator (OMSA) on Dell PowerEdge servers.

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with omsa](#setup)
    * [What omsa affects](#what-omsa-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with omsa](#beginning-with-omsa)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Upgrading from vpgrp-omsa](#upgrading-from-vpgrp-omsa)
1. [Development](#development)

## Description

OMSA reports and configures a PowerEdge server's hardware: `omreport` and `omconfig` for chassis, storage controllers and disks, plus SNMP agents. This module adds Dell's package repository with Dell's signing key, installs the OMSA packages and keeps the OMSA services running.

By default it only acts on physical servers whose DMI manufacturer starts with "Dell", so it can be included on every host.

## Setup

### What omsa affects

* Debian and Ubuntu: `/etc/apt/sources.list.d/dell-omsa.list` and the keyring `/etc/apt/keyrings/dell-omsa.asc`.
* Red Hat family: the yum repository `dell-omsa` and `/etc/pki/rpm-gpg/RPM-GPG-KEY-dell-omsa`.
* The packages `srvadmin-base`, `srvadmin-storageservices` and `srvadmin-omcommon` and their dependencies.
* The services `instsvcdrv`, `dsm_sa_datamgrd` and `dsm_sa_eventmgrd`.
* With `non_dell_certified_flag` set: `NonDellCertifiedFlag` in `/opt/dell/srvadmin/etc/srvadmin-storage/stsvc.ini`.

### Setup requirements

* Puppet 7 or 8.
* puppetlabs-stdlib, puppetlabs-apt (Debian/Ubuntu) and puppetlabs-inifile. puppetlabs-yumrepo_core is listed for the Red Hat family; Puppet's agent packages already include it.
* Access to `https://linux.dell.com`, or a mirror (`manage_repo => false`).

### Beginning with omsa

```puppet
include omsa
```

## Usage

Report alerts for drives that Dell hasn't certified (OMSA suppresses them by default):

```puppet
class { 'omsa':
  non_dell_certified_flag => false,
}
```

Use packages from a repository that's already configured:

```puppet
class { 'omsa':
  manage_repo => false,
}
```

Install OMSA on a node the default fact check skips:

```puppet
class { 'omsa':
  manage => true,
}
```

With Hiera:

```yaml
omsa::non_dell_certified_flag: false
omsa::package_names:
  - 'srvadmin-base'
  - 'srvadmin-storageservices'
  - 'srvadmin-server-cli'
```

## Reference

See [REFERENCE.md](REFERENCE.md).

## Limitations

| OS | OMSA | Repository |
|---|---|---|
| Ubuntu 22.04 | 11.1.0.0 | `linux.dell.com/repo/community/openmanage/11100/jammy` |
| Debian 12, 13 | 11.1.0.0 | the same jammy repository (Dell doesn't build for Debian) |
| RHEL, Rocky, AlmaLinux 8 and 9 | 11.1.0.0 | `linux.dell.com/repo/hardware/dsu/os_dependent/RHEL<major>_64` |
| CentOS 7, RHEL 7 | 10.1.0.0 | `linux.dell.com/repo/hardware/DSU_22.08.12/os_dependent/RHEL7_64` (Dell's last EL7 release) |

* Dell supports OMSA on Ubuntu 22.04 and RHEL 8/9, not on Debian. The jammy packages install on Debian 12 and 13 (checked with `apt-get -s`), but Dell won't support them there.
* Dell has no OMSA for RHEL 10, Ubuntu 24.04 or later; the iDRAC Service Module is its successor.
* `dsu/` is Dell's rolling DSU repository, so EL8/9 pick up new OMSA releases when Dell publishes them. Pin a dated `DSU_YY.MM.DD` with `omsa::repo::yum_baseurl` to hold a version.
* amd64/x86_64 only.

## Upgrading from vpgrp-omsa

* `omsa::repos` is now `omsa::repo`; rename any Hiera keys (`omsa::repos::apt_location` → `omsa::repo::apt_location`, and so on). `os_dependent_url` is `yum_baseurl`; the `os_independent` repository (DSU itself) is no longer added.
* `manage_install` and `manage_config` are now `manage`. `package_name` is `package_names` and `service_name` is `service_names` (both arrays).
* `ignore_dell_certified => true` is now `non_dell_certified_flag => false`.
* The `/etc/dell` symlink, the Augeas lens in Puppet's lens directory and the old `/etc/yum.repos.d/omsa.repo` are no longer managed. Remove them once:
  `rm -f /etc/dell /opt/puppetlabs/puppet/share/augeas/lenses/omsa.aug /etc/yum.repos.d/omsa.repo`.
* On Debian/Ubuntu the old source was `omsa`, with its key in apt-key's keyring. Remove `/etc/apt/sources.list.d/omsa.list` and the old key: `apt-key del 34D8786F`.

## Development

Pull requests are welcome at <https://github.com/freepenguins/puppet-omsa>. Run the checks with:

```bash
bundle install
bundle exec rake lint rubocop syntax metadata_lint spec
```

Originally written by Richard Delaplace for Vente-Privée as `vpgrp-omsa`.
