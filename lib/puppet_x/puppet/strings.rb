require 'puppet'
require 'puppet/pops'
require 'puppet/util/docs'
require 'yard'

module PuppetX
end

# Nothing to see here except forward declarations.
module PuppetX::Puppet
  module Strings
    # This submodule contains bits that operate on the Pops module produced by
    # the Future parser.
    module Pops
      require 'puppet_x/puppet/strings/pops/yard_statement'
      require 'puppet_x/puppet/strings/pops/yard_transformer'
    end

    # This submodule contains bits that interface with the YARD plugin system.
    module YARD
      require 'puppet_x/puppet/strings/yard/monkey_patches'
      require 'puppet_x/puppet/strings/yard/parser'

      module Tags
        require 'puppet_x/puppet/strings/yard/tags/directives'
      end

      # This submodule contains code objects which are used to represent relevant
      # aspects of puppet code in YARD's Registry
      module CodeObjects
        require 'puppet_x/puppet/strings/yard/code_objects/puppet_namespace_object'
        require 'puppet_x/puppet/strings/yard/code_objects/method_object'
        require 'puppet_x/puppet/strings/yard/code_objects/defined_type_object'
        require 'puppet_x/puppet/strings/yard/code_objects/host_class_object'
        require 'puppet_x/puppet/strings/yard/code_objects/type_object'
        require 'puppet_x/puppet/strings/yard/code_objects/provider_object'
      end

      # This submodule contains handlers which are used to extract relevant data about
      # puppet code from the ASTs produced by the Ruby and Puppet parsers
      module Handlers
        # This utility library contains some tools for working with Puppet docstrings
        require 'puppet_x/puppet/strings/yard/handlers/base'
        require 'puppet_x/puppet/strings/yard/handlers/defined_type_handler'
        require 'puppet_x/puppet/strings/yard/handlers/host_class_handler'
        require 'puppet_x/puppet/strings/yard/handlers/puppet_3x_function_handler'
        require 'puppet_x/puppet/strings/yard/handlers/puppet_4x_function_handler'
        require 'puppet_x/puppet/strings/yard/handlers/type_handler'
        require 'puppet_x/puppet/strings/yard/handlers/provider_handler'
      end

      ::YARD::Parser::SourceParser.register_parser_type(:puppet,
        PuppetX::Puppet::Strings::YARD::PuppetParser,
        ['pp'])
      ::YARD::Handlers::Processor.register_handler_namespace(:puppet,
        PuppetX::Puppet::Strings::YARD::Handlers)

      # FIXME: Might not be the best idea to have the template code on the Ruby
      # LOAD_PATH as the contents of this directory really aren't library code.
      ::YARD::Templates::Engine.register_template_path(
        File.join(File.dirname(__FILE__), 'strings', 'yard', 'templates'))
    end
  end
end
