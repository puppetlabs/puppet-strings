require 'puppet'
require 'puppet/pops'
require 'puppet/util/docs'
require 'yard'

module PuppetX
end

# Nothing to see here except forward declarations.
module PuppetX::PuppetLabs
  module Strings
    # This submodule contains bits that operate on the Pops module produced by
    # the Future parser.
    module Pops
      require 'puppet_x/puppetlabs/strings/pops/yard_statement'
      require 'puppet_x/puppetlabs/strings/pops/yard_transformer'
    end

    # This submodule contains bits that interface with the YARD plugin system.
    module YARD
      require 'puppet_x/puppetlabs/strings/yard/monkey_patches'
      require 'puppet_x/puppetlabs/strings/yard/parser'

      module Tags
        require 'puppet_x/puppetlabs/strings/yard/tags/directives'
      end

      # This submodule contains code objects which are used to represent relevant
      # aspects of puppet code in YARD's Registry
      module CodeObjects
        require 'puppet_x/puppetlabs/strings/yard/code_objects/puppet_namespace_object'
        require 'puppet_x/puppetlabs/strings/yard/code_objects/defined_type_object'
        require 'puppet_x/puppetlabs/strings/yard/code_objects/host_class_object'
        require 'puppet_x/puppetlabs/strings/yard/code_objects/type_object'
        require 'puppet_x/puppetlabs/strings/yard/code_objects/provider_object'
      end

      # This submodule contains handlers which are used to extract relevant data about
      # puppet code from the ASTs produced by the Ruby and Puppet parsers
      module Handlers
        # This utility library contains some tools for working with Puppet docstrings
        require 'puppet_x/puppetlabs/strings/yard/handlers/base'
        require 'puppet_x/puppetlabs/strings/yard/handlers/defined_type_handler'
        require 'puppet_x/puppetlabs/strings/yard/handlers/host_class_handler'
        require 'puppet_x/puppetlabs/strings/yard/handlers/puppet_3x_function_handler'
        require 'puppet_x/puppetlabs/strings/yard/handlers/puppet_4x_function_handler'
        require 'puppet_x/puppetlabs/strings/yard/handlers/type_handler'
        require 'puppet_x/puppetlabs/strings/yard/handlers/provider_handler'
      end

      ::YARD::Parser::SourceParser.register_parser_type(:puppet,
        PuppetX::PuppetLabs::Strings::YARD::PuppetParser,
        ['pp'])
      ::YARD::Handlers::Processor.register_handler_namespace(:puppet,
        PuppetX::PuppetLabs::Strings::YARD::Handlers)

      # FIXME: Might not be the best idea to have the template code on the Ruby
      # LOAD_PATH as the contents of this directory really aren't library code.
      ::YARD::Templates::Engine.register_template_path(
        File.join(File.dirname(__FILE__), 'strings', 'yard', 'templates'))
    end
  end
end
