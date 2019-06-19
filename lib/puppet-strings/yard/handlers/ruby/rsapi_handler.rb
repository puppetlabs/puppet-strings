require 'puppet-strings/yard/handlers/helpers'
require 'puppet-strings/yard/handlers/ruby/base'
require 'puppet-strings/yard/code_objects'
require 'puppet-strings/yard/util'

# Implements the handler for Puppet resource types written in Ruby.
class PuppetStrings::Yard::Handlers::Ruby::RsapiHandler < PuppetStrings::Yard::Handlers::Ruby::Base
  # The default docstring when ensurable is used without given a docstring.
  DEFAULT_ENSURABLE_DOCSTRING = 'The basic property that the resource should be in.'.freeze

  namespace_only
  handles method_call(:register_type)

  process do
    # Only accept calls to Puppet::ResourceApi
    return unless statement.count > 1
    module_name = statement[0].source
    return unless ['Puppet::ResourceApi'].include? module_name

    schema = extract_schema

    # puts "Schema: #{schema.inspect}"

    object = PuppetStrings::Yard::CodeObjects::Type.new(schema['name'])
    register object

    docstring = schema['docs']
    if docstring
      register_docstring(object, PuppetStrings::Yard::Util.scrub_string(docstring.to_s), nil)
    else
      log.warn "Missing a description for Puppet resource type '#{object.name}' at #{statement.file}:#{statement.line}."
    end

    # Populate the parameters/properties/features to the type
    populate_type_data(object, schema)

    # Mark the type as public if it doesn't already have an api tag
    object.add_tag YARD::Tags::Tag.new(:api, 'public') unless object.has_tag? :api

    # Warn if a summary longer than 140 characters was provided
    PuppetStrings::Yard::Handlers::Helpers.validate_summary_tag(object) if object.has_tag? :summary
  end

  private

  def raise_parse_error(msg, location = statement)
    raise YARD::Parser::UndocumentableError, "#{msg} at #{location.file}:#{location.line}."
  end

  # check that the params of the register_type call are key/value pairs.
  def kv_arg_list?(params)
    params.type == :list && params.children.count > 0 && params.children.first.type == :list && params.children.first.children.count > 0 && statement.parameters.children.first.children.first.type == :assoc
  end

  def extract_schema
    raise_parse_error("Expected list of key/value pairs as argument") unless kv_arg_list?(statement.parameters)
    hash_from_node(statement.parameters.children.first)
  end

  def value_from_node(node)
    return nil unless node

    # puts "value from #{node.inspect}"

    case node.type
    when :int
      node.source.to_i
    when :hash
      hash_from_node(node)
    when :array
      array_from_node(node)
    when :var_ref
      var_ref_from_node(node)
    when :symbol, :symbol_literal, :label, :dyna_symbol, :string_literal, :regexp_literal
      node_as_string(node)
    else
      raise_parse_error("unexpected construct #{node.type}")
    end
  end

  def array_from_node(node)
    return nil unless node

    arr = node.children.collect do |assoc|
      value_from_node(assoc.children[0])
    end
  end

  def hash_from_node(node)
    return nil unless node

    # puts "hash from #{node.inspect}"

    kv_pairs = node.children.collect do |assoc|
      [value_from_node(assoc.children[0]), value_from_node(assoc.children[1])]
    end
    Hash[kv_pairs]
  end

  def var_ref_from_node(node)
    return nil unless node

    # puts "var_ref from #{node.inspect}"

    if node.children.first.type == :kw
      case node.children.first.source
      when "false"
        return false
      when "true"
        return true
      when "nil"
        return nil
      else
        raise_parse_error("unexpected keyword '#{node.children.first.source}'")
      end
    end
    raise_parse_error("unexpected variable")
  end


  def populate_type_data(object, schema)
    return if schema['attributes'].nil?

    schema['attributes'].each do |name, definition|
      # puts "Processing #{name}: #{definition.inspect}"
      if ['parameter', 'namevar'].include? definition['behaviour']
        object.add_parameter(create_parameter(name, definition))
      else
        object.add_property(create_property(name, definition))
      end
    end
  end

  def create_parameter(name, definition)
    parameter = PuppetStrings::Yard::CodeObjects::Type::Parameter.new(name, definition['desc'])
    set_values(definition, parameter)
    parameter
  end

  def create_property(name, definition)
    property = PuppetStrings::Yard::CodeObjects::Type::Property.new(name, definition['desc'])
    set_values(definition, property)
    property
  end

  def set_values(definition, object)
    object.data_type = definition['type'] if definition.key? 'type'
    object.default = definition['default'] if definition.key? 'default'
    object.isnamevar = definition.key?('behaviour') && definition['behaviour'] == 'namevar'
  end
end
