# The module for custom YARD handlers.
module PuppetStrings::Yard::Handlers
  # The module for custom Ruby YARD handlers.
  module Ruby
    require 'puppet-strings/yard/handlers/ruby/data_type_handler'
    require 'puppet-strings/yard/handlers/ruby/type_handler'
    require 'puppet-strings/yard/handlers/ruby/type_extras_handler'
    require 'puppet-strings/yard/handlers/ruby/rsapi_handler'
    require 'puppet-strings/yard/handlers/ruby/provider_handler'
    require 'puppet-strings/yard/handlers/ruby/function_handler'
  end

  # The module for custom JSON YARD handlers.
  module JSON
    require 'puppet-strings/yard/handlers/json/task_handler'
  end

  # The module for custom Puppet YARD handlers.
  module Puppet
    require 'puppet-strings/yard/handlers/puppet/class_handler'
    require 'puppet-strings/yard/handlers/puppet/data_type_alias_handler'
    require 'puppet-strings/yard/handlers/puppet/defined_type_handler'
    require 'puppet-strings/yard/handlers/puppet/function_handler'
    require 'puppet-strings/yard/handlers/puppet/plan_handler'
  end
end
