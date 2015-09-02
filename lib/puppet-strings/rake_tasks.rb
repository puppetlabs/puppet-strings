require 'rake'
require 'rake/tasklib'
require 'puppet/face'
require 'puppet_x/puppetlabs/strings/util'

namespace :strings do
  desc 'Generate Puppet documentation with YARD.'
  task :generate do
    PuppetX::PuppetLabs::Strings::Util.generate
  end

  desc 'Serve YARD documentation for modules.'
  task :serve do
    PuppetX::PuppetLabs::Strings::Util.serve
  end
end
