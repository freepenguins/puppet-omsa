# -*- puppet -*-

class { 'omsa':
  package => true,
  service => false,
  enable  => false,
  force   => true,
}
# EOF
