# Packages come from a repository that's already configured (a local mirror).
class { 'omsa':
  manage_repo   => false,
  package_names => ['srvadmin-base', 'srvadmin-storageservices', 'srvadmin-server-cli'],
}
