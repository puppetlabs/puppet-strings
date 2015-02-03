class PuppetX::PuppetLabs::Strings::YARD::Handlers::Puppet3xFunctionHandler < YARD::Handlers::Ruby::Base
  include PuppetX::PuppetLabs::Strings::YARD::CodeObjects

  handles method_call(:newfunction)

  process do
    name, options = process_parameters

    obj = MethodObject.new(function_namespace, name)

    register obj
    if options['doc']
      register_docstring(obj, options['doc'], nil)
    end

    # This has to be done _after_ register_docstring as all tags on the
    # object are overwritten by tags parsed out of the docstring.
    return_type = options['type']
    return_type ||= 'statement' # Default for newfunction
    obj.add_tag YARD::Tags::Tag.new(:return, '', return_type)

    # FIXME: This is a hack that allows us to document the Puppet Core which
    # uses `--no-transitive-tag api` and then only shows things explicitly
    # tagged with `public` or `private` api. This is kind of insane and
    # should be fixed upstream.
    obj.add_tag YARD::Tags::Tag.new(:api, 'public')
  end

  private

  # Returns a {PuppetNamespaceObject} for holding functions. Creates this
  # object if necessary.
  #
  # @return [PuppetNamespaceObject]
  def function_namespace
    # NOTE: This tricky. If there is ever a Ruby class or module with the
    # name ::Puppet3xFunctions, then there will be a clash. Hopefully the name
    # is sufficiently uncommon.
    obj = P(:root, 'Puppet3xFunctions')
    if obj.is_a? Proxy
      namespace_obj = PuppetNamespaceObject.new(:root, 'Puppet3xFunctions')
      namespace_obj.add_tag YARD::Tags::Tag.new(:api, 'public')

      register namespace_obj
    end

    obj
  end

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
