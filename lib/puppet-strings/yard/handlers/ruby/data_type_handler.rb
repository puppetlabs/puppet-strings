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

    actual_params = extract_params_for_data_type

    # Mark the data type as public if it doesn't already have an api tag
    object.add_tag YARD::Tags::Tag.new(:api, 'public') unless object.has_tag? :api

    validate_tags!(object, actual_params)

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

  def extract_params_for_data_type
    params = {}
    # Traverse the block looking for interface
    block = statement.block
    return unless block && block.count >= 2
    block[1].children.each do |node|
      next unless node.is_a?(YARD::Parser::Ruby::MethodCallNode) &&
                  node.method_name

      method_name = node.method_name.source
      parameters = node.parameters(false)
      if method_name == 'interface'
        next unless parameters.count >= 1
        interface_string = node_as_string(parameters[0])
        next unless interface_string
        # Ref - https://github.com/puppetlabs/puppet/blob/ba4d1a1aba0095d3c70b98fea5c67434a4876a61/lib/puppet/datatypes.rb#L159
        parsed_interface = nil
        begin
          parsed_interface = Puppet::Pops::Parser::EvaluatingParser.new.parse_string("{ #{interface_string} }").body
        rescue Puppet::Error => e
          log.warn "Invalid datatype definition at #{statement.file}:#{statement.line}: #{e.basic_message}"
          next
        end
        next unless parsed_interface

        # Now that we parsed the Puppet code (as a string) into a LiteralHash PCore type (Puppet AST),
        #
        # We need to convert the LiteralHash into a conventional ruby hash of strings. The
        # LazyLiteralEvaluator does this by traversing the AST tree can converting objects to strings
        # where possible and ignoring object types which cannot (thus the 'Lazy' name)
        #
        # Once we have it as a standard ruby hash we can then look at the keys and populate the YARD
        # Code object with the correct attributes etc.
        literal_eval = LazyLiteralEvaluator.new
        populate_data_type_params_from_literal_hash!(literal_eval.literal(parsed_interface), params)
      end
    end
    params
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
      @literal_visitor ||= ::Puppet::Pops::Visitor.new(self, "literal", 0, 0)
    end

    def literal(ast)
      @literal_visitor.visit_this_0(self, ast)
    end

    # ----- The following methods are different/additions from the original Literal_evaluator
    def literal_Object(o) # rubocop:disable Naming/UncommunicativeMethodParamName
      # Ignore any other object types
    end

    def literal_AccessExpression(o) # rubocop:disable Naming/UncommunicativeMethodParamName
      # Extract the raw text of the Access Expression
      ::Puppet::Pops::Adapters::SourcePosAdapter.adapt(o).extract_text
    end

    def literal_QualifiedReference(o) # rubocop:disable Naming/UncommunicativeMethodParamName
      # Extract the raw text of the Qualified Reference
      ::Puppet::Pops::Adapters::SourcePosAdapter.adapt(o).extract_text
    end

    # ----- The following methods are the same as the original Literal_evaluator
    def literal_Factory(o) # rubocop:disable Naming/UncommunicativeMethodParamName
      literal(o.model)
    end

    def literal_Program(o) # rubocop:disable Naming/UncommunicativeMethodParamName
      literal(o.body)
    end

    def literal_LiteralString(o) # rubocop:disable Naming/UncommunicativeMethodParamName
      o.value
    end

    def literal_QualifiedName(o) # rubocop:disable Naming/UncommunicativeMethodParamName
      o.value
    end

    def literal_LiteralNumber(o) # rubocop:disable Naming/UncommunicativeMethodParamName
      o.value
    end

    def literal_UnaryMinusExpression(o) # rubocop:disable Naming/UncommunicativeMethodParamName
      -1 * literal(o.expr)
    end

    def literal_LiteralBoolean(o) # rubocop:disable Naming/UncommunicativeMethodParamName
      o.value
    end

    def literal_LiteralUndef(o) # rubocop:disable Naming/UncommunicativeMethodParamName
      nil
    end

    def literal_LiteralDefault(o) # rubocop:disable Naming/UncommunicativeMethodParamName
      :default
    end

    def literal_LiteralRegularExpression(o) # rubocop:disable Naming/UncommunicativeMethodParamName
      o.value
    end

    def literal_ConcatenatedString(o) # rubocop:disable Naming/UncommunicativeMethodParamName
      # use double quoted string value if there is no interpolation
      throw :not_literal unless o.segments.size == 1 && o.segments[0].is_a?(Model::LiteralString)
      o.segments[0].value
    end

    def literal_LiteralList(o) # rubocop:disable Naming/UncommunicativeMethodParamName
      o.values.map {|v| literal(v) }
    end

    def literal_LiteralHash(o) # rubocop:disable Naming/UncommunicativeMethodParamName
      o.entries.reduce({}) do |result, entry|
        result[literal(entry.key)] = literal(entry.value)
        result
      end
    end
  end

  def populate_data_type_params_from_literal_hash!(hash, params_hash)
    return if hash.nil?
    # Exit early if there are no entries in the hash
    return if hash['attributes'].nil? || hash['attributes'].count.zero?

    hash['attributes'].each do |key, value|
      data_type = nil
      default = nil
      case value
      when String
        data_type = value
      when Hash
        data_type = value['type'] unless value['type'].nil?
        default   = value['value'] unless value['value'].nil?
      end
      data_type = [data_type] unless data_type.nil? || data_type.is_a?(Array)
      params_hash[key] = { :types => data_type, :default => default }
    end
  end

  def validate_tags!(object, actual_params_hash)
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
end
