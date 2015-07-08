# Handles `dispatch` calls within a future parser function declaration. For
# now, it just treats any docstring as an `@overlaod` tag and attaches the
# overload to the parent function.
class PuppetX::PuppetLabs::Strings::YARD::Handlers::Puppet4xFunctionHandler < YARD::Handlers::Ruby::Base
  include PuppetX::PuppetLabs::Strings::YARD::CodeObjects

  handles method_call(:dispatch)

  process do
    return unless owner.is_a?(MethodObject) && owner['puppet_4x_function']
    return unless statement.docstring

    docstring = ::YARD::Docstring.new(statement.docstring, nil)

    # FIXME: This does a wholesale copy of all possible tags. But, we're only
    # interested in the @overload tag.
    owner.add_tag *docstring.tags
  end
end

class Puppet4xFunctionHandler < YARD::Handlers::Ruby::Base
  include PuppetX::PuppetLabs::Strings::YARD::CodeObjects

  handles method_call(:create_function)

  # Given a command node which represents code like this:
  # param  'Optional[Type]',   :value_type
  # Extract the type name and type signature and return them as a array.
  def extract_type_from_command command
    return [] if command.children.length < 2 or command.children[1].children.length < 2
    type_specifier = command.children[1]
    # the parameter signature is the first child of the specifier and an
    # identifier. Convert it to a string.
    param_signature = type_specifier.children[0].source
    # The parameter name is the second child of the specifier and a symbol.
    # convert it to a string.
    param_name_ident = type_specifier.jump :ident
    return [] if param_name_ident == type_specifier
    param_name = param_name_ident.source
    [param_name, param_signature]
  end

  process do
    name = process_parameters

    method_arguments = []

    # To attach the method parameters to the new code object, traverse the
    # ruby AST until a node is found which defines a array of parameters.
    # Then, traverse the children of the parameters, storing each identifier
    # in the array of method arguments.
    obj = MethodObject.new(function_namespace, name) do |o|
    end

    # The data structure for overload_signatures is an array of hashes. Each
    # hash represents the arguments a single function dispatch (aka overload)
    # can take.
    # overload_signatures = [
    #   { # First function dispatch arguments
    #     # argument name, argument type
    #     'arg0': 'Variant[String,Array[String]]',
    #     'arg1': 'Optional[Type]'
    #   },
    #   { # Second function dispatch arguments
    #     'arg0': 'Variant[String,Array[String]]',
    #     'arg1': 'Optional[Type]',
    #     'arg2': 'Any'
    #   }
    # ]
    # Note that the order for arguments to a function doesn't actually matter
    # because we allow users flexibility when listing their arguments in the
    # comments.
    overload_signatures = []
    statement.traverse do |node|
      # Find all of the dispatch methods
      if node.type == :ident and node.source == 'dispatch'
        command = node.parent
        do_block = command.jump :do_block
        # If the command doesn't have a do_block we can't extract type info
        if do_block == command
          next
        end
        signature = {}
        # Iterate through each of the children of the do block and build
        # tuples of parameter names and parameter type signatures
        do_block.children.first.children.each do |child|
          name, type = extract_type_from_command(child)
          # This can happen if there is a function or something we aren't
          # expecting.
          if name != nil and type != nil
            signature[name] = type
          end
        end
        overload_signatures <<= signature
      end
    end

    # If the overload_signatures list is empty because we couldn't find any
    # dispatch blocks, then there must be one function named the same as the
    # name of the function being created.
    if overload_signatures.length == 0
      statement.traverse do |node|
        # Find the function definition with the same name as the puppet
        # function being created.
        if (node.type == :def and node.children.first.type == :ident and
            node.children.first.source == obj.name.to_s)
          signature = {}
          # Find its parameters. If they don't exist, fine
          params = node.jump :params
          break if params == node
          params.traverse do |param|
            if param.type == :ident
              # The parameters of Puppet functions with no defined dispatch are
              # as though they are Any type.
              signature[param[0]] =  'Any'
            end
          end
          overload_signatures <<= signature
          # Now that the parameters have been found, break out of the traversal
          break
        end
      end
    end

    # Preserve this type information. We'll need it later when we look
    # at the docstring.
    obj.type_info = overload_signatures

    # The yard docstring parser expects a list of lists, not a list of lists of
    # lists.
    obj.parameters = overload_signatures.map { |sig| sig.to_a }.flatten(1)

    obj['puppet_4x_function'] = true

    register obj

    obj.add_tag YARD::Tags::Tag.new(:api, 'public')

    blk = statement.block.children.first
    parse_block(blk, :owner => obj)
  end

  private

  # Returns a {PuppetNamespaceObject} for holding functions. Creates this
  # object if necessary.
  #
  # @return [PuppetNamespaceObject]
  def function_namespace
    # NOTE: This tricky. If there is ever a Ruby class or module with the
    # name ::Puppet4xFunctions, then there will be a clash. Hopefully the name
    # is sufficiently uncommon.
    obj = P(:root, 'Puppet4xFunctions')
    if obj.is_a? Proxy
      namespace_obj = PuppetNamespaceObject.new(:root, 'Puppet4xFunctions')

      register namespace_obj
      # FIXME: The docstring has to be cleared. Otherwise, the namespace
      # object will be registered using the docstring of the
      # `create_function` call that is currently being processed.
      #
      # Figure out how to properly register the namespace without using the
      # function handler object.
      register_docstring(namespace_obj, '', nil)
      namespace_obj.add_tag YARD::Tags::Tag.new(:api, 'public')
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
    # Passing `false` to parameters excludes the block param from the returned
    # array.
    name, _ = statement.parameters(false).compact

    name = process_element(name)

    name
  end

  # Sometimes the YARD parser returns Heredoc strings that start with `<-`
  # instead of `<<-`.
  HEREDOC_START = /^<?<-/

    # Turns an entry in the method parameter array into a string.
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
