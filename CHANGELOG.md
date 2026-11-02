# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [4.0.0] - 2026-11-02

First release as `freepenguins-omsa`, forked from `vpgrp-omsa` 3.0.1.

### Added
- PDK 3.4.0 layout, rspec-puppet specs for every supported OS, REFERENCE.md and `examples/`.
- Debian 13, RHEL/Rocky/AlmaLinux 8 and 9.
- `omsa::repo` adds Dell's key from the module (PGRE 2012, `42550ABD1E80D7C1BC0BAD851285491434D8786F`): a `signed-by` keyring on Debian/Ubuntu, `/etc/pki/rpm-gpg/RPM-GPG-KEY-dell-omsa` on the Red Hat family.
- `non_dell_certified_flag` sets `NonDellCertifiedFlag` in `stsvc.ini` with `ini_setting`.

### Changed
- Puppet `>= 7.0.0 < 9.0.0`; stdlib 9, apt 9–10, inifile 5–6, yumrepo_core 1–2.
- OMSA 11.1.0.0: Debian/Ubuntu use `openmanage/11100/jammy`, EL8/9 use DSU's `os_dependent/RHEL<major>_64`. EL7 stays on OMSA 10.1.0.0 (`DSU_22.08.12`).
- `omsa::repos` is now `omsa::repo`; install, config and service are private classes.
- `manage_install`/`manage_config` are replaced by `manage`, which reads structured facts (`dmi.manufacturer`, `is_virtual`).
- `package_name` is `package_names`, `service_name` is `service_names`; the services are `instsvcdrv`, `dsm_sa_datamgrd` and `dsm_sa_eventmgrd`.
- Default `package_ensure` is `installed`.

### Removed
- Debian 7–11, Ubuntu 12.04–20.04, CentOS 6.
- `apt-key` keys, the templated yum `.repo` file and its `yum update -q -y` exec.
- The custom Augeas lens and the `augeas_*`/`ignore_dell_certified` parameters (use `non_dell_certified_flag`).
- The `/etc/dell` symlink (`symlink_directory`): OMSA 11 has no `/etc/opt/dell`.
- `service_hasrestart`, `service_hasstatus` and the `*_require`/`*_notify` parameters.

## [3.0.1] and earlier

Released by vpgrp as `vpgrp-omsa`.
