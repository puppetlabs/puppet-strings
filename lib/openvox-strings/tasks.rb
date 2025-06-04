# frozen_string_literal: true

require 'rake'
require 'rake/tasklib'

# Ensure OpenvoxStrings is loaded.
module OpenvoxStrings end

# The module for Puppet Strings rake tasks.
module OpenvoxStrings::Tasks
  require 'openvox-strings/tasks/generate'
  require 'openvox-strings/tasks/gh_pages'
  require 'openvox-strings/tasks/validate'
end
