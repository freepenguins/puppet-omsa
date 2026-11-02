# Report alerts for drives that Dell hasn't certified.
class { 'omsa':
  non_dell_certified_flag => false,
}
