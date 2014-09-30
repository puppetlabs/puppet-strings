require 'puppetx'

# Nothing to see here except forward declarations.
module Puppetx::PuppetLabs
  module Strings
    require 'puppet/pops'

    # This submodule contains bits that interface with the YARD plugin system.
    module YARD
      require 'yard'

      # This submodule contains code objects which are used to represent relevant
      # aspects of puppet code in YARD's Registry
      module CodeObjects
        require 'puppetx/puppetlabs/strings/yard/code_objects/puppet_namespace_object'
        require 'puppetx/puppetlabs/strings/yard/code_objects/defined_type_object'
        require 'puppetx/puppetlabs/strings/yard/code_objects/host_class_object'
      end

      # This submodule contains handlers which are used to extract relevant data about
      # puppet code from the ASTs produced by the Ruby and Puppet parsers
      module Handlers
        # This utility library contains some tools for working with Puppet docstrings
        require 'puppet/util/docs'
        require 'puppetx/puppetlabs/strings/yard/handlers/base'
        require 'puppetx/puppetlabs/strings/yard/handlers/defined_type_handler'
        require 'puppetx/puppetlabs/strings/yard/handlers/host_class_handler'
        require 'puppetx/puppetlabs/strings/yard/handlers/puppet_3x_function_handler'
        require 'puppetx/puppetlabs/strings/yard/handlers/puppet_4x_function_handler'
      end
    end

    # This submodule contains bits that operate on the Pops module produced by
    # the Future parser.
    module Pops
      require 'puppetx/puppetlabs/strings/pops/yard_statement'
      require 'puppetx/puppetlabs/strings/pops/yard_transformer'
    end
  end
end
