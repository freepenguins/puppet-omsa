# frozen_string_literal: true

require 'spec_helper'

['omsa::install', 'omsa::config', 'omsa::service'].each do |klass|
  describe klass do
    let(:facts) { on_supported_os['debian-12-x86_64'] }

    it { is_expected.to compile.and_raise_error(%r{private}) }
  end
end
