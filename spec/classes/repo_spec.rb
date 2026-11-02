# frozen_string_literal: true

require 'spec_helper'

describe 'omsa::repo' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }

      context 'with ensure => absent' do
        let(:params) { { ensure: 'absent' } }

        it { is_expected.to compile.with_all_deps }

        it 'removes the repository' do
          if os_facts[:os]['family'] == 'Debian'
            is_expected.to contain_apt__source('dell-omsa').with_ensure('absent')
          else
            is_expected.to contain_yumrepo('dell-omsa').with_ensure('absent')
            is_expected.to contain_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-dell-omsa').with_ensure('absent')
          end
        end
      end

      if os_facts[:os]['family'] == 'Debian'
        context 'with another release' do
          let(:params) { { apt_location: 'https://linux.dell.com/repo/community/openmanage/11010/jammy' } }

          it { is_expected.to contain_apt__source('dell-omsa').with_location('https://linux.dell.com/repo/community/openmanage/11010/jammy') }
        end
      else
        context 'with a mirror' do
          let(:params) { { yum_baseurl: 'https://mirror.example.com/dell/RHEL9_64/', yum_name: 'mirror-omsa' } }

          it { is_expected.to contain_yumrepo('mirror-omsa').with_baseurl('https://mirror.example.com/dell/RHEL9_64/') }
        end
      end
    end
  end

  context 'on an unsupported OS' do
    let(:facts) { { os: { 'family' => 'Suse', 'name' => 'SLES', 'release' => { 'major' => '15' } } } }

    it { is_expected.to compile.and_raise_error(%r{SLES is not supported}) }
  end
end
