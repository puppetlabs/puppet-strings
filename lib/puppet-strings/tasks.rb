require 'rake'
require 'rake/tasklib'

module PuppetStrings
  # The module for Puppet Strings rake tasks.
  module Tasks
    require 'puppet-strings/tasks/generate.rb'
    require 'puppet-strings/tasks/gh_pages.rb'
  end
end
