# == Class: omsa
#
# Puppet module to install, deploy and configure omsa.
#
# [*augeas_context*]
# required if augeas_incl and augeas_lens (faster) are undef,
# typically '/files/opt/dell/srvadmin/etc/srvadmin-storage/stsvc.ini'
#
# [*augeas_load_path*]
# necessary if lens is not in /opt/puppetlabs/puppet/share/augeas/lenses
#
class omsa (
  Boolean                                  $manage_install          = $facts[is_virtual] ? { true => false, default => $facts[manufacturer] ? { 'Dell Inc.' => true, default => false } },
  Boolean                                  $manage_config           = $manage_install,
  Boolean                                  $manage_repos            = true,
  Boolean                                  $manage_service          = $manage_install,
  Boolean                                  $symlink_directory       = true,
  Variant[String, Array[String]]           $package_name            = [ 'srvadmin-base', 'srvadmin-storageservices', 'srvadmin-omcommon' ],
  String                                   $package_ensure          = 'present',
  Optional[Variant[Type, Array[Type]]]     $package_require         = [ Class['omsa::repos' ] ],
  String                                   $service_ensure          = 'running',
  Boolean                                  $service_enable          = true,
  Boolean                                  $service_hasrestart      = true,
  Boolean                                  $service_hasstatus       = true,
  Optional[Variant[Type, Array[Type]]]     $service_require         = Package[$package_name],
  String                                   $service_name            = 'dataeng',

  Boolean                                  $ignore_dell_certified   = false,
  String                                   $augeas_name             = 'omsa_stsvc_nondell',
  Optional[String]                         $augeas_context          = undef,
  Optional[String]                         $augeas_incl             = '/opt/dell/srvadmin/etc/srvadmin-storage/stsvc.ini',
  Optional[String]                         $augeas_lens             = 'Omsa.lns',
  String                                   $augeas_lens_file        = '/opt/puppetlabs/puppet/share/augeas/lenses/omsa.aug',
  String                                   $augeas_lens_file_source = 'puppet:///modules/omsa/omsa.aug',
  String                                   $augeas_lens_file_ensure = 'present',
  Optional[Variant[String, Array[String]]] $augeas_load_path        = undef,
  String                                   $augeas_onlyif           = "get general/NonDellCertifiedFlag != 'no'",
  String                                   $augeas_changes          = "set general/NonDellCertifiedFlag 'no'",
  Optional[Variant[Type, Array[Type]]]     $augeas_notify           = Service[$service_name],
  Optional[Variant[Type, Array[Type]]]     $augeas_require          = File[$augeas_lens_file],
) {

  if $manage_install {
    if $manage_repos {
      class { 'omsa::repos': }
    }

    ensure_packages($package_name, { ensure  => $package_ensure, require => $package_require })
  }

  if $manage_config {
    if $ignore_dell_certified {
      file { $augeas_lens_file :
        ensure => $augeas_lens_file_ensure,
        source => $augeas_lens_file_source,
      }
      augeas { $augeas_name:
        context   => $augeas_context,
        incl      => $augeas_incl,
        lens      => $augeas_lens,
        load_path => $augeas_load_path,
        onlyif    => $augeas_onlyif,
        changes   => $augeas_changes,
        notify    => $augeas_notify,
        require   => $augeas_require,
      }
    }
  }

  if $manage_service {
    service { $service_name:
      ensure     => $service_ensure,
      enable     => $service_enable,
      hasrestart => $service_hasrestart,
      hasstatus  => $service_hasstatus,
      require    => $service_require,
    }

    #file { '/usr/sbin/omreport':
    #  ensure  => symlink,
    #  path    => '/usr/sbin/omreport',
    #  target  => '/opt/dell/srvadmin/bin/omreport',
    #  require => Package[$omsa_package_name],
    #}

    if $symlink_directory {
      file { '/etc/dell':
        ensure  => symlink,
        path    => '/etc/dell',
        target  => '/etc/opt/dell',
        require => Package[$package_name],
      }
    }

    # if ($service == true) {
    #   exec { '/etc/init.d/dataeng enablesnmp ':
    #     command     => '/etc/init.d/dataeng enablesnmp ',
    #     refreshonly => true,
    #     notify      => Service[$omsa_service_name],
    #     require     => Package[$omsa_package_name],
    #   }
    # }
  }
}
# EOF
