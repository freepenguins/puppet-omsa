# @summary Keeps the OMSA services running.
#
# @api private
class omsa::service {
  assert_private()

  service { $omsa::service_names:
    ensure => $omsa::service_ensure,
    enable => $omsa::service_enable,
  }
}
