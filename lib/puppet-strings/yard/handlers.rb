# The module for custom YARD handlers.
module PuppetStrings::Yard::Handlers
  # The module for custom Puppet YARD handlers.
  module Puppet
    require 'puppet-strings/yard/handlers/puppet/class_handler'
    require 'puppet-strings/yard/handlers/puppet/defined_type_handler'
  end
end
