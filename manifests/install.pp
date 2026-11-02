# @summary Installs the OMSA packages.
#
# @api private
class omsa::install {
  assert_private()

  package { $omsa::package_names:
    ensure => $omsa::package_ensure,
  }
}
