# -*- puppet -*-

exec { 'apt-get update':
  command => 'apt-get update -qq',
  path    => [ '/usr/bin', '/usr/sbin', '/bin', '/sbin' ],
}

class { 'omsa':
  package => true,
  service => false,
  enable  => false,
  force   => true,
  require => Exec[ 'apt-get update' ],
}
# EOF
