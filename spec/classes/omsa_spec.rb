# frozen_string_literal: true

require 'spec_helper'

describe 'omsa' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:dell_facts) do
        os_facts.merge(
          is_virtual: false,
          dmi: (os_facts[:dmi] || {}).merge('manufacturer' => 'Dell Inc.'),
        )
      end
      let(:facts) { dell_facts }
      let(:family) { os_facts[:os]['family'] }
      let(:major) { os_facts[:os]['release']['major'] }

      context 'with defaults on a physical Dell server' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('omsa::repo').that_comes_before('Class[omsa::install]') }
        it { is_expected.to contain_class('omsa::install').that_comes_before('Class[omsa::config]') }
        it { is_expected.to contain_class('omsa::config').that_notifies('Class[omsa::service]') }
        it { is_expected.to contain_class('omsa::service') }

        ['srvadmin-base', 'srvadmin-storageservices', 'srvadmin-omcommon'].each do |pkg|
          it { is_expected.to contain_package(pkg).with_ensure('installed') }
        end

        ['instsvcdrv', 'dsm_sa_datamgrd', 'dsm_sa_eventmgrd'].each do |svc|
          it { is_expected.to contain_service(svc).with(ensure: 'running', enable: true) }
        end

        it { is_expected.not_to contain_ini_setting('omsa NonDellCertifiedFlag') }

        it 'adds the right repository for the OS' do
          case family
          when 'Debian'
            is_expected.to contain_apt__source('dell-omsa').with(
              location: 'https://linux.dell.com/repo/community/openmanage/11100/jammy',
              release: 'jammy',
              repos: 'main',
              architecture: 'amd64',
            )
            is_expected.to contain_apt__keyring('dell-omsa.asc')
            is_expected.to contain_class('apt::update').that_comes_before('Class[omsa::install]')
          when 'RedHat'
            url = if major == '7'
                    'https://linux.dell.com/repo/hardware/DSU_22.08.12/os_dependent/RHEL7_64/'
                  else
                    "https://linux.dell.com/repo/hardware/dsu/os_dependent/RHEL#{major}_64/"
                  end
            is_expected.to contain_yumrepo('dell-omsa').with(
              baseurl: url,
              enabled: '1',
              gpgcheck: '1',
              gpgkey: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-dell-omsa',
            ).that_requires('File[/etc/pki/rpm-gpg/RPM-GPG-KEY-dell-omsa]')
            is_expected.to contain_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-dell-omsa')
              .with_content(%r{BEGIN PGP PUBLIC KEY BLOCK})
          end
        end
      end

      context 'on a virtual machine' do
        let(:facts) { dell_facts.merge(is_virtual: true) }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to have_package_resource_count(0) }
        it { is_expected.to have_service_resource_count(0) }
        it { is_expected.not_to contain_class('omsa::repo') }
      end

      context 'on another vendor\'s hardware' do
        let(:facts) { dell_facts.merge(dmi: { 'manufacturer' => 'Supermicro' }) }

        it { is_expected.to have_package_resource_count(0) }
      end

      context 'with manage => true on a VM' do
        let(:facts) { dell_facts.merge(is_virtual: true) }
        let(:params) { { manage: true } }

        it { is_expected.to contain_package('srvadmin-base') }
      end

      context 'with manage_repo => false' do
        let(:params) { { manage_repo: false } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.not_to contain_class('omsa::repo') }
        it { is_expected.not_to contain_apt__source('dell-omsa') }
        it { is_expected.not_to contain_yumrepo('dell-omsa') }
        it { is_expected.to contain_package('srvadmin-base') }
      end

      context 'with manage_service => false' do
        let(:params) { { manage_service: false } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.not_to contain_class('omsa::service') }
        it { is_expected.to have_service_resource_count(0) }
      end

      [[true, 'yes'], [false, 'no']].each do |flag, value|
        context "with non_dell_certified_flag => #{flag}" do
          let(:params) { { non_dell_certified_flag: flag } }

          it { is_expected.to compile.with_all_deps }
          it {
            is_expected.to contain_ini_setting('omsa NonDellCertifiedFlag').with(
              ensure: 'present',
              path: '/opt/dell/srvadmin/etc/srvadmin-storage/stsvc.ini',
              section: 'general',
              setting: 'NonDellCertifiedFlag',
              value: value,
              key_val_separator: '=',
            )
          }
          it { is_expected.to contain_ini_setting('omsa NonDellCertifiedFlag').that_notifies('Service[dsm_sa_datamgrd]') }
        end
      end

      context 'with package_ensure => absent' do
        let(:params) { { package_ensure: 'absent', non_dell_certified_flag: false } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_package('srvadmin-base').with_ensure('absent') }
        it { is_expected.to have_service_resource_count(0) }
        it { is_expected.not_to contain_ini_setting('omsa NonDellCertifiedFlag') }
      end

      context 'with custom packages and services' do
        let(:params) { { package_names: ['srvadmin-all'], service_names: ['dsm_sa_datamgrd'], service_ensure: 'stopped', service_enable: false } }

        it { is_expected.to contain_package('srvadmin-all') }
        it { is_expected.not_to contain_package('srvadmin-base') }
        it { is_expected.to contain_service('dsm_sa_datamgrd').with(ensure: 'stopped', enable: false) }
        it { is_expected.not_to contain_service('instsvcdrv') }
      end

      context 'with an empty package list' do
        let(:params) { { package_names: [] } }

        it { is_expected.to compile.and_raise_error(%r{package_names}) }
      end
    end
  end

  # facterdb has no EL7 facts for Facter 4.3+ (Puppet 7.34 and 8.10), so EL7
  # reuses RedHat 8's facts with the release changed.
  ['CentOS', 'RedHat'].each do |name|
    context "on #{name} 7" do
      let(:facts) do
        base = on_supported_os['redhat-8-x86_64']
        base.merge(
          os: base[:os].merge('name' => name, 'release' => { 'full' => '7.9.2009', 'major' => '7', 'minor' => '9' }),
          is_virtual: false,
          dmi: { 'manufacturer' => 'Dell Inc.' },
        )
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_yumrepo('dell-omsa').with_baseurl('https://linux.dell.com/repo/hardware/DSU_22.08.12/os_dependent/RHEL7_64/') }
      it { is_expected.to contain_package('srvadmin-base') }
      it { is_expected.to contain_service('dsm_sa_datamgrd') }
    end
  end
end
