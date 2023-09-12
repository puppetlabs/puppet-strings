# frozen_string_literal: true

require 'puppet-strings/yard/handlers/helpers'
require 'puppet-strings/yard/handlers/ruby/base'
require 'puppet-strings/yard/code_objects'
require 'puppet-strings/yard/util'

# Implements the handler for Puppet Data Types written in Ruby.
class PuppetStrings::Yard::Handlers::Ruby::DataTypeHandler < PuppetStrings::Yard::Handlers::Ruby::Base
  namespace_only
  handles method_call(:create_type)

  process do
    return unless statement.count > 1

    ruby_module_name = statement[0].source
    return unless ruby_module_name == 'Puppet::DataTypes' || ruby_module_name == 'DataTypes' # rubocop:disable Style/MultipleComparison This reads better

    object = get_datatype_yard_object(get_name(statement, 'Puppet::DataTypes.create_type'))
    # Extract the interface definition
    type_interface = extract_data_type_interface
    actual_params = extract_params(type_interface)
    actual_funcs = extract_functions(object, type_interface)

    # Mark the data type as public if it doesn't already have an api tag
    object.add_tag YARD::Tags::Tag.new(:api, 'public') unless object.has_tag? :api

    validate_param_tags!(object, actual_params)
    validate_methods!(object, actual_funcs)

    # Set the default values for all parameters
    actual_params.each { |name, data| object.set_parameter_default(name, data[:default]) }

    # Default any typeless param tag to 'Any'
    object.tags(:param).each do |tag|
      tag.types = ['Any'] unless tag.types && !tag.types.empty?
    end

    # Warn if a summary longer than 140 characters was provided
    PuppetStrings::Yard::Handlers::Helpers.validate_summary_tag(object) if object.has_tag? :summary
  end

  private

  def get_datatype_yard_object(name)
    # Have to guess the path - if we create the object to get the true path from the code,
    # it also shows up in the .at call - self registering?
    guess_path = "puppet_data_types::#{name}"
    object = YARD::Registry.at(guess_path)

    return object unless object.nil?

    # Didn't find, create instead
    object = PuppetStrings::Yard::CodeObjects::DataType.new(name)
    register object
    object
  end

  # @return [Hash{Object => Object}] The Puppet DataType interface definition as a ruby Hash
  def extract_data_type_interface
    block = statement.block
    return {} unless block

    # Declare the parsed interface outside of the closure
    parsed_interface = nil

    # Recursively traverse the block looking for the first valid 'interface' call
    find_ruby_ast_node(block, true) do |node|
      next false unless node.is_a?(YARD::Parser::Ruby::MethodCallNode) &&
                        node.method_name &&
                        node.method_name.source == 'interface'

      parameters = node.parameters(false)
      next false unless parameters.count >= 1

      interface_string = node_as_string(parameters[0])
      next false unless interface_string

      begin
        # Ref - https://github.com/puppetlabs/puppet/blob/ba4d1a1aba0095d3c70b98fea5c67434a4876a61/lib/puppet/datatypes.rb#L159
        parsed_interface = Puppet::Pops::Parser::EvaluatingParser.new.parse_string("{ #{interface_string} }").body
      rescue Puppet::Error => e
        log.warn "Invalid datatype definition at #{statement.file}:#{statement.line}: #{e.basic_message}"
        next false
      end
      !parsed_interface.nil?
    end

    # Now that we parsed the Puppet code (as a string) into a LiteralHash PCore type (Puppet AST),
    # We need to convert the LiteralHash into a conventional ruby hash of strings. The
    # LazyLiteralEvaluator does this by traversing the AST tree can converting objects to strings
    # where possible and ignoring object types which cannot (thus the 'Lazy' name)
    literal_eval = LazyLiteralEvaluator.new
    literal_eval.literal(parsed_interface)
  end

  # Find the first Ruby AST node within an AST Tree, optionally recursively. Returns nil of none could be found
  #
  # @param [YARD::Parser::Ruby::AstNode] ast_node The root AST node object to inspect
  # @param [Boolean] recurse Whether to search the tree recursively.  Defaults to false
  # @yieldparam [YARD::Parser::Ruby::AstNode] ast_node The AST Node that should be checked
  # @yieldreturn [Boolean] Whether the node was what was searched for
  # @return [YARD::Parser::Ruby::AstNode, nil]
  def find_ruby_ast_node(ast_node, recurse = false, &block)
    raise ArgumentError, 'find_ruby_ast_node requires a block' unless block

    is_found = yield ast_node
    return ast_node if is_found

    if ast_node.respond_to?(:children)
      ast_node.children.each do |child_node|
        child_found = find_ruby_ast_node(child_node, recurse, &block)
        return child_found unless child_found.nil?
      end
    end
    nil
  end

  # Lazily evaluates a Pops object, ignoring any objects that cannot
  # be converted to a literal value. Based on the Puppet Literal Evaluator
  # Ref - https://github.com/puppetlabs/puppet/blob/ba4d1a1aba0095d3c70b98fea5c67434a4876a61/lib/puppet/pops/evaluator/literal_evaluator.rb
  #
  # Literal values for:
  # String (not containing interpolation)
  # Numbers
  # Booleans
  # Undef (produces nil)
  # Array
  # Hash
  # QualifiedName
  # Default (produced :default)
  # Regular Expression (produces ruby regular expression)
  # QualifiedReference  e.g. File, FooBar
  # AccessExpression
  #
  # Anything else is ignored
  class LazyLiteralEvaluator
    def initialize
      @literal_visitor = ::Puppet::Pops::Visitor.new(self, 'literal', 0, 0)
    end

    def literal(ast)
      @literal_visitor.visit_this_0(self, ast)
    end

    # TODO: Fix the rubocop violations in this file between the following rubocop:disable/enable lines
    # rubocop:disable Naming/MethodName
    # ----- The following methods are different/additions from the original Literal_evaluator
    def literal_Object(o)
      # Ignore any other object types
    end

    def literal_AccessExpression(o)
      # Extract the raw text of the Access Expression
      PuppetStrings::Yard::Util.ast_to_text(o)
    end

    def literal_QualifiedReference(o)
      # Extract the raw text of the Qualified Reference
      PuppetStrings::Yard::Util.ast_to_text(o)
    end

    # ----- The following methods are the same as the original Literal_evaluator
    def literal_Factory(o)
      literal(o.model)
    end

    def literal_Program(o)
      literal(o.body)
    end

    def literal_LiteralString(o)
      o.value
    end

    def literal_QualifiedName(o)
      o.value
    end

    def literal_LiteralNumber(o)
      o.value
    end

    def literal_UnaryMinusExpression(o)
      -1 * literal(o.expr)
    end

    def literal_LiteralBoolean(o)
      o.value
    end

    def literal_LiteralUndef(_o)
      nil
    end

    def literal_LiteralDefault(_o)
      :default
    end

    def literal_LiteralRegularExpression(o)
      o.value
    end

    def literal_ConcatenatedString(o)
      # use double quoted string value if there is no interpolation
      throw :not_literal unless o.segments.size == 1 && o.segments[0].is_a?(Model::LiteralString)
      o.segments[0].value
    end

    def literal_LiteralList(o)
      o.values.map { |v| literal(v) }
    end

    def literal_LiteralHash(o)
      o.entries.each_with_object({}) do |entry, result|
        result[literal(entry.key)] = literal(entry.value)
      end
    end
    # rubocop:enable Naming/MethodName
  end

  # Extracts the datatype attributes from a Puppet Data Type interface hash.
  # Returns a Hash with a :types key (Array of data types for the parameter) and :default key (The default value of the parameter)
  # @return Hash[Symbol => Hash] The Datatype Attributes as a hash
  def extract_params(hash)
    params_hash = {}
    # Exit early if there are no entries in the hash
    return params_hash if hash.nil? || hash['attributes'].nil? || hash['attributes'].empty?

    hash['attributes'].each do |key, value|
      data_type = nil
      default = nil
      if value.is_a?(String)
        data_type = value
      elsif value.is_a?(Hash)
        data_type = value['type'] unless value['type'].nil?
        default   = value['value'] unless value['value'].nil?
      end
      data_type = [data_type] unless data_type.nil? || data_type.is_a?(Array)
      params_hash[key] = { types: data_type, default: default }
    end

    params_hash
  end

  # Extracts the datatype functions from a Puppet Data Type interface hash.
  # Returns a Hash with a :param_types key (Array of types for each parameter) and :return_type key (The return type of the function)
  # @return Hash[Symbol => Hash] The Datatype Attributes as a hash
  def extract_functions(object, hash)
    funcs_hash = {}
    # Exit early if there are no entries in the hash
    return funcs_hash if hash.nil? || hash['functions'].nil? || hash['functions'].empty?

    hash['functions'].each do |key, func_type|
      func_hash = { param_types: [], return_type: nil }
      begin
        callable_type = Puppet::Pops::Types::TypeParser.singleton.parse(func_type)
        if callable_type.is_a?(Puppet::Pops::Types::PCallableType)
          func_hash[:param_types] = callable_type.param_types.map(&:to_s)
          func_hash[:return_type] = callable_type.return_type.to_s
        else
          log.warn "The function definition for '#{key}' near #{object.file}:#{object.line} is not a Callable type"
        end
      rescue Puppet::ParseError => e
        log.warn "Unable to parse the function definition for '#{key}' near #{object.file}:#{object.line}. #{e}"
      end
      funcs_hash[key] = func_hash
    end
    funcs_hash
  end

  # Validates and automatically fixes yard @param tags for the data type
  def validate_param_tags!(object, actual_params_hash)
    actual_param_names = actual_params_hash.keys
    tagged_param_names = object.tags(:param).map(&:name)
    # Log any errors
    # Find attributes which are not documented
    (actual_param_names - tagged_param_names).each do |item|
      log.warn "Missing @param tag for attribute '#{item}' near #{object.file}:#{object.line}."
    end
    # Find param tags with no matching attribute
    (tagged_param_names - actual_param_names).each do |item|
      log.warn "The @param tag for '#{item}' has no matching attribute near #{object.file}:#{object.line}."
    end
    # Find param tags with a type that is different from the actual definition
    object.tags(:param).reject { |tag| tag.types.nil? }.each do |tag|
      next if actual_params_hash[tag.name].nil?

      actual_data_type = actual_params_hash[tag.name][:types]
      next if actual_data_type.nil?

      log.warn "The @param tag for '#{tag.name}' has a different type definition than the actual attribute near #{object.file}:#{object.line}." if tag.types != actual_data_type
    end

    # Automatically fix missing @param tags
    (actual_param_names - tagged_param_names).each do |name|
      object.add_parameter(name, actual_params_hash[name][:types], actual_params_hash[name][:default])
    end
    # Remove extra param tags
    object.docstring.delete_tag_if { |item| item.tag_name == 'param' && !actual_param_names.include?(item.name) }

    # Set the type in the param tag
    object.tags(:param).each do |tag|
      next if actual_params_hash[tag.name].nil?

      tag.types = actual_params_hash[tag.name][:types]
    end
  end

  # Validates and automatically fixes yard @method! tags for the data type
  def validate_methods!(object, actual_functions_hash)
    actual_func_names = actual_functions_hash.keys
    tagged_func_names = object.meths.map { |meth| meth.name.to_s }

    # Log any errors
    # Find functions which are not documented
    (actual_func_names - tagged_func_names).each do |item|
      log.warn "Missing @!method tag for function '#{item}' near #{object.file}:#{object.line}."
    end
    # Find functions which are not defined
    (tagged_func_names - actual_func_names).each do |item|
      log.warn "The @!method tag for '#{item}' has no matching function definition near #{object.file}:#{object.line}."
    end
    # Functions with the wrong return type
    object.meths.each do |meth|
      next unless actual_func_names.include?(meth.name.to_s)

      return_tag = meth.docstring.tag(:return)
      next if return_tag.nil?

      actual_return_types = [actual_functions_hash[meth.name.to_s][:return_type]]
      next if return_tag.types == actual_return_types

      log.warn "The @return tag for '#{meth.name}' has a different type definition than the actual function near #{object.file}:#{object.line}. Expected #{actual_return_types}"
      return_tag.types = actual_return_types
    end

    # Automatically fix missing methods
    (actual_func_names - tagged_func_names).each do |name|
      object.add_function(name, actual_functions_hash[name][:return_type], actual_functions_hash[name][:param_types])
    end
    # Remove extra methods. Can't use `meths` as that's a derived property
    object.children.reject! { |child| child.is_a?(YARD::CodeObjects::MethodObject) && !actual_func_names.include?(child.name.to_s) }

    # Add the return type for the methods if missing
    object.meths.each do |meth|
      next unless meth.docstring.tag(:return).nil?

      meth.docstring.add_tag(YARD::Tags::Tag.new(:return, '', actual_functions_hash[meth.name.to_s][:return_type]))
    end

    # Sync the method properties and add the return type for the methods if missing
    object.meths.each do |meth|
      validate_function_method!(object, meth, actual_functions_hash[meth.name.to_s])
      next unless meth.docstring.tag(:return).nil?

      meth.docstring.add_tag(YARD::Tags::Tag.new(:return, '', actual_functions_hash[meth.name.to_s][:return_type]))
    end

    # The default meth.signature assumes ruby invocation (e.g. def meth(...)) but this doesn't make sense for a
    # Puppet Data Type function invocation. So instead we derive a signature from the method definition.
    object.meths.each do |meth|
      params = ''
      params += "(#{meth.docstring.tags(:param).map(&:name).join(', ')})" unless meth.docstring.tags(:param).empty?
      meth.signature = "#{object.name}.#{meth.name}" + params
    end

    nil
  end

  # Validates and automatically fixes a single yard @method!
  # Used by the validate_methods! method.
  def validate_function_method!(object, meth, actual_function)
    # Remove extra params
    if meth.docstring.tags(:param).count > actual_function[:param_types].count
      index = 0
      meth.docstring.delete_tag_if do |tag|
        if tag.tag_name == 'param'
          index += 1
          if index > actual_function[:param_types].count
            log.warn "The @param tag for '#{tag.name}' should not exist for function " \
                     "'#{meth.name}' that is defined near #{object.file}:#{object.line}. " \
                     "Expected only #{actual_function[:param_types].count} parameter/s"
            true
          else
            false
          end
        else
          false
        end
      end
    end

    # Add missing params
    if meth.docstring.tags(:param).count < actual_function[:param_types].count
      start = meth.docstring.tags(:param).count + 1
      (start..actual_function[:param_types].count).each do |param_type_index| # Using 1-based index here instead of usual zero
        meth.add_tag(YARD::Tags::Tag.new(:param, '', actual_function[:param_types][param_type_index - 1], "param#{param_type_index}"))
      end
    end

    # Ensure the parameter types are correct
    meth.docstring.tags(:param).each_with_index do |tag, actual_type_index|
      actual_types = [actual_function[:param_types][actual_type_index]]
      if tag.types != actual_types
        log.warn "The @param tag for '#{tag.name}' for function '#{meth.name}' has a different type definition than the actual function near #{object.file}:#{object.line}. Expected #{actual_types}"
        tag.types = actual_types
      end
    end
  end
end
