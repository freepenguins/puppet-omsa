# @summary Adds Dell's OMSA package repository.
#
# On Debian and Ubuntu an APT source with Dell's key in its own keyring
# (`signed-by`); on the Red Hat family a yum repository checked with the same
# key, installed in `/etc/pki/rpm-gpg`. The key (fingerprint
# `4255 0ABD 1E80 D7C1 BC0B AD85 1285 4914 34D8 786F`) ships with the module.
#
# @example Use another OMSA release on Ubuntu 22.04
#   class { 'omsa::repo':
#     apt_location => 'https://linux.dell.com/repo/community/openmanage/11010/jammy',
#   }
#
# @param ensure
#   `present` or `absent`.
# @param apt_location
#   APT repository URL.
# @param apt_release
#   APT suite. Dell names it after the Ubuntu codename it builds for.
# @param apt_repos
#   APT component.
# @param apt_architecture
#   Architecture for the APT source. Dell's repository also lists i386, which
#   has only a few packages.
# @param yum_baseurl
#   Yum repository URL.
# @param yum_name
#   Name of the yum repository.
# @param key_file
#   Path of Dell's key on the Red Hat family.
class omsa::repo (
  Enum['present', 'absent'] $ensure = 'present',
  Optional[Stdlib::HTTPUrl] $apt_location = undef,
  Optional[String[1]] $apt_release = undef,
  String[1] $apt_repos = 'main',
  String[1] $apt_architecture = 'amd64',
  Optional[Stdlib::HTTPUrl] $yum_baseurl = undef,
  String[1] $yum_name = 'dell-omsa',
  Stdlib::Absolutepath $key_file = '/etc/pki/rpm-gpg/RPM-GPG-KEY-dell-omsa',
) {
  case $facts['os']['family'] {
    'Debian': {
      unless $apt_location and $apt_release {
        fail('omsa::repo: apt_location and apt_release must be set on Debian and Ubuntu')
      }
      include apt

      apt::source { 'dell-omsa':
        ensure       => $ensure,
        location     => $apt_location,
        release      => $apt_release,
        repos        => $apt_repos,
        architecture => $apt_architecture,
        key          => {
          'name'    => 'dell-omsa.asc',
          'content' => file('omsa/dell-openmanage.asc'),
        },
        include      => { 'src' => false, 'deb' => true },
      }
    }
    'RedHat': {
      unless $yum_baseurl {
        fail('omsa::repo: yum_baseurl must be set on the Red Hat family')
      }

      file { $key_file:
        ensure  => $ensure,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => file('omsa/dell-openmanage.asc'),
      }

      yumrepo { $yum_name:
        ensure   => $ensure,
        descr    => 'Dell OpenManage Server Administrator',
        baseurl  => $yum_baseurl,
        enabled  => '1',
        gpgcheck => '1',
        gpgkey   => "file://${key_file}",
        require  => File[$key_file],
      }
    }
    default: {
      fail("omsa::repo: ${facts['os']['name']} is not supported")
    }
  }
}
