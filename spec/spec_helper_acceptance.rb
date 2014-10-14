require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'

unless ENV['RS_PROVISION'] == 'no'
  install_puppet
end

RSpec.configure do |c|

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do

  hosts.each do |host|
      scp_to(host, Dir.glob('pkg/puppetlabs-strings*.gz').first, 'strings.tar.gz')
      on host, puppet('module', 'install', 'strings.tar.gz')

      scp_to(host, Dir.glob('spec/unit/puppet/examples/test/pkg/username-test*.gz').first, 'test.tar.gz')
      on host, puppet('module', 'install', 'test.tar.gz')

      on host, 'gem install yard'
      on host, 'gem install rgen'
    end
  end
end
