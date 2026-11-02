# frozen_string_literal: true

require 'spec_helper'
require 'open3'

# The key Dell signs the jammy and DSU repositories and RPMs with.
describe 'files/dell-openmanage.asc' do
  let(:path) { File.expand_path('../../files/dell-openmanage.asc', __dir__) }

  it 'is Dell PGRE 2012 (42550ABD1E80D7C1BC0BAD851285491434D8786F)' do
    skip 'gpg not installed' unless system('command -v gpg >/dev/null 2>&1')
    out, status = Open3.capture2('gpg', '--batch', '--with-colons', '--show-keys', path)
    expect(status).to be_success
    fprs = out.lines.select { |l| l.start_with?('fpr:') }.map { |l| l.split(':')[9] }
    expect(fprs.first).to eq('42550ABD1E80D7C1BC0BAD851285491434D8786F')
  end
end
