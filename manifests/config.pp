# @summary Sets OMSA storage service options.
#
# @api private
class omsa::config {
  assert_private()

  if $omsa::non_dell_certified_flag != undef and $omsa::package_ensure != 'absent' {
    ini_setting { 'omsa NonDellCertifiedFlag':
      ensure            => present,
      path              => '/opt/dell/srvadmin/etc/srvadmin-storage/stsvc.ini',
      section           => 'general',
      setting           => 'NonDellCertifiedFlag',
      value             => bool2str($omsa::non_dell_certified_flag, 'yes', 'no'),
      key_val_separator => '=',
    }
  }
}
