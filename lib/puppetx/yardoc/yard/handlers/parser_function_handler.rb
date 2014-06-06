# This utility library contains some tools for working with Puppet docstrings.
require 'puppet/util/docs'

require_relative 'base'

module Puppetx::Yardoc::YARD::Handlers
  class ParserFunctionHandler < YARD::Handlers::Ruby::Base
    handles method_call(:newfunction)

    process do
      name, options = process_parameters

      obj = MethodObject.new(:root, name)

      register obj
      if options['doc']
        register_docstring(obj, options['doc'], nil)
      end

      # This has to be done _after_ register_docstring as all tags on the
      # object are overwritten by tags parsed out of the docstring.
      return_type = options['type']
      return_type ||= 'statement' # Default for newfunction
      obj.add_tag YARD::Tags::Tag.new(:return, '', return_type)
    end

    private

    # NOTE: The following methods duplicate functionality from
    # Puppet::Util::Reference and Puppet::Parser::Functions.functiondocs
    #
    # However, implementing this natively in YARD is a good test for the
    # feasibility of extracting custom Ruby documentation. In the end, the
    # existing approach taken by Puppet::Util::Reference may be the best due to
    # the heavy use of metaprogramming in Types and Providers.

    # Extracts the Puppet function name and options hash from the parsed
    # definition.
    #
    # @return [(String, Hash{String => String})]
    def process_parameters
      # Passing `false` to prameters excludes the block param from the returned
      # list.
      name, opts = statement.parameters(false).compact

      name = process_element(name)

      opts = opts.map do |tuple|
        # Jump down into the S-Expression that represents a hashrocket, `=>`,
        # and the values on either side of it.
        tuple.jump(:assoc).map{|e| process_element(e)}
      end

      [name, Hash[opts]]
    end

    # Sometimes the YARD parser returns Heredoc strings that start with `<-`
    # instead of `<<-`.
    HEREDOC_START = /^<?<-/

    # Turns an entry in the method parameter list into a string.
    #
    # @param ele [YARD::Parser::Ruby::AstNode]
    # @return [String]
    def process_element(ele)
      ele = ele.jump(:ident, :string_content)

      case ele.type
      when :ident
        ele.source
      when :string_content
        source = ele.source
        if HEREDOC_START.match(source)
          process_heredoc(source)
        else
          source
        end
      end
    end

    # Cleans up and formats Heredoc contents parsed by YARD.
    #
    # @param source [String]
    # @return [String]
    def process_heredoc(source)
      source = source.lines.to_a

      # YARD adds a line of source context on either side of the Heredoc
      # contents.
      source.shift
      source.pop

      # This utility method normalizes indentation and trims whitespace.
      Puppet::Util::Docs.scrub(source.join)
    end
  end
end
