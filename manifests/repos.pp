# == Class: omsa::repos
#
# This is a container class holding default parameters for omsa module.
#
# http://linux.dell.com/repo/community/
#
class omsa::repos (
  String  $ensure        = 'present',
  String  $apt_repo      = 'omsa',
  String  $apt_location  = 'http://linux.dell.com/repo/community/ubuntu/',
  String  $apt_release   = $facts[os][distro][codename],
  String  $apt_repos     = 'openmanage',
  String  $apt_key       = '42550ABD1E80D7C1BC0BAD851285491434D8786F',
  String  $file_name     = '/etc/yum.repos.d/omsa.repo',
  Boolean $file_backup   = true,
  String  $file_template = 'omsa/yum.repo.erb',
  String  $file_owner    = 'root',
  String  $file_group    = 'root',
  String  $file_mode     = '0644',
  String  $os_dependent_url   = 'http://linux.dell.com/repo/hardware/latest/os_dependent/',
  String  $os_dependent_key   = 'http://linux.dell.com/repo/hardware/latest/public.key',
  String  $os_independent_url = 'http://linux.dell.com/repo/hardware/latest/os_independent/',
  String  $os_independent_key = 'http://linux.dell.com/repo/hardware/latest/public.key',
) {
  case $facts[os][family] {
    'Debian': {
      require apt
      apt::source { $apt_repo :
        ensure   => $ensure,
        location => $apt_location,
        release  => $apt_release,
        repos    => $apt_repos,
        key      => $apt_key,
      }
    }
    'RedHat': {
      file { $file_name:
        ensure  => $ensure,
        backup  => $file_backup,
        content => template($file_template),
        owner   => $file_owner,
        group   => $file_group,
        mode    => $file_mode,
      }

      exec { 'omsa_yum_update':
        command   => 'yum update -q -y',
        path      => [ '/usr/bin', '/usr/sbin', '/bin', '/sbin' ],
        subscribe => File[$file_name],
      }
    }
    default                    : {
      fail("Module ${module_name} is not supported on ${::operatingsystem}")
    }
  }
}
# EOF
