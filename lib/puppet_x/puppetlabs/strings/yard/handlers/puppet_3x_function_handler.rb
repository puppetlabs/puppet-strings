require File.join(File.dirname(__FILE__),'./heredoc_helper')

class PuppetX::PuppetLabs::Strings::YARD::Handlers::Puppet3xFunctionHandler < YARD::Handlers::Ruby::Base
  include PuppetX::PuppetLabs::Strings::YARD::CodeObjects

  handles method_call(:newfunction)

  process do
    @heredoc_helper = HereDocHelper.new
    name, options = @heredoc_helper.process_parameters statement

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

end
