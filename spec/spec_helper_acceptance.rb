require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), 'acceptance/lib'))
require 'util'

unless ENV['RS_PROVISION'] == 'no'
  install_puppet
end

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    extend PuppetStrings::Acceptance::CommandUtils
    hosts.each do |host|
      scp_to(host, Dir.glob('puppet-strings*.gem').first, 'puppet-strings.gem')
      install_ca_certs(host)
      on host, "#{gem_command(host)} install yard"
      on host, "#{gem_command(host)} install rgen"
      on host, "#{gem_command(host)} install puppet-strings.gem"

      scp_to(host, Dir.glob('spec/fixtures/acceptance/modules/test/pkg/username-test*.gz').first, 'test.tar.gz')
      on host, puppet('module', 'install', 'test.tar.gz')
    end
  end
end
