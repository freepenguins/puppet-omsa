# @summary Installs and configures Dell OpenManage Server Administrator (OMSA).
#
# Adds Dell's package repository, installs the OMSA packages, optionally sets
# storage service options and keeps the OMSA services running. By default the
# class only acts on physical Dell servers, so it can be included everywhere.
#
# @example Include it on every host; only physical Dell servers get OMSA
#   include omsa
#
# @example Report alerts for drives that Dell hasn't certified
#   class { 'omsa':
#     non_dell_certified_flag => false,
#   }
#
# @example Use a local mirror of Dell's repository
#   class { 'omsa':
#     manage_repo => false,
#   }
#
# @param manage
#   Whether to manage OMSA on this node at all. Defaults to true only on
#   physical servers whose DMI manufacturer starts with "Dell".
# @param manage_repo
#   Whether to add Dell's package repository (see `omsa::repo`). Set it to
#   false when the packages come from a repository that's already configured.
# @param manage_service
#   Whether to manage the OMSA services.
# @param package_names
#   OMSA packages to install. The defaults give `omreport` and `omconfig`
#   with storage support.
# @param package_ensure
#   `ensure` for the packages: `installed`, `latest`, `absent` or a version.
# @param service_names
#   OMSA services to manage.
# @param service_ensure
#   `ensure` for the services.
# @param service_enable
#   Whether the services start at boot.
# @param non_dell_certified_flag
#   Value of `NonDellCertifiedFlag` in `stsvc.ini`. `true` (OMSA's default)
#   suppresses alerts for drives that Dell hasn't certified; `false` reports
#   them. Unset leaves the file alone.
class omsa (
  Boolean $manage = (!$facts['is_virtual'] and $facts.dig('dmi', 'manufacturer') =~ /\ADell/),
  Boolean $manage_repo = true,
  Boolean $manage_service = true,
  Array[String[1], 1] $package_names = ['srvadmin-base', 'srvadmin-storageservices', 'srvadmin-omcommon'],
  String[1] $package_ensure = 'installed',
  Array[String[1]] $service_names = ['instsvcdrv', 'dsm_sa_datamgrd', 'dsm_sa_eventmgrd'],
  Stdlib::Ensure::Service $service_ensure = 'running',
  Boolean $service_enable = true,
  Optional[Boolean] $non_dell_certified_flag = undef,
) {
  if $manage {
    if $manage_repo {
      contain omsa::repo
      Class['omsa::repo'] -> Class['omsa::install']
      if $facts['os']['family'] == 'Debian' {
        Class['apt::update'] -> Class['omsa::install']
      }
    }

    contain omsa::install
    contain omsa::config

    Class['omsa::install'] -> Class['omsa::config']

    if $manage_service and $package_ensure != 'absent' {
      contain omsa::service
      Class['omsa::install'] -> Class['omsa::service']
      Class['omsa::config'] ~> Class['omsa::service']
    }
  }
}
