# frozen_string_literal: true

require 'rake'
require 'rake/tasklib'

# Ensure PuppetStrings is loaded.
module PuppetStrings end

# The module for Puppet Strings rake tasks.
module PuppetStrings::Tasks
  require 'puppet-strings/tasks/generate'
  require 'puppet-strings/tasks/gh_pages'
  require 'puppet-strings/tasks/validate'
end
