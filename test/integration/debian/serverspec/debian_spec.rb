# -*- ruby -*-

require 'serverspec'

set :backend, :exec

installed_packages = [
  'srvadmin-base',
  'srvadmin-storageservices',
  'srvadmin-omcommon'
]

describe 'Packages' do
  installed_packages.each do |pkg|
    describe package(pkg) do
      it { should be_installed }
    end
  end
end
# EOF
