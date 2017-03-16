require 'puppet-strings/yard/handlers/helpers'
require 'puppet-strings/yard/handlers/ruby/base'
require 'puppet-strings/yard/code_objects'
require 'puppet-strings/yard/util'

# Implements the handler for Puppet resource types written in Ruby.
class PuppetStrings::Yard::Handlers::Ruby::TypeHandler < PuppetStrings::Yard::Handlers::Ruby::Base
  # The default docstring when ensurable is used without given a docstring.
  DEFAULT_ENSURABLE_DOCSTRING = 'The basic property that the resource should be in.'.freeze

  namespace_only
  handles method_call(:newtype)

  process do
    # Only accept calls to Puppet::Type
    return unless statement.count > 1
    module_name = statement[0].source
    return unless module_name == 'Puppet::Type' || module_name == 'Type'

    object = PuppetStrings::Yard::CodeObjects::Type.new(get_name)
    register object

    docstring = find_docstring(statement, "Puppet resource type '#{object.name}'")
    register_docstring(object, docstring, nil) if docstring

    # Populate the parameters/properties/features to the type
    populate_type_data(object)

    # Set the default namevar
    set_default_namevar(object)

    # Mark the type as public if it doesn't already have an api tag
    object.add_tag YARD::Tags::Tag.new(:api, 'public') unless object.has_tag? :api

    # Warn if a summary longer than 140 characters was provided
    PuppetStrings::Yard::Handlers::Helpers.validate_summary_tag(object) if object.has_tag? :summary
  end

  private
  def get_name
    parameters = statement.parameters(false)
    raise YARD::Parser::UndocumentableError, "Expected at least one parameter to Puppet::Type.newtype at #{statement.file}:#{statement.line}." if parameters.empty?
    name = node_as_string(parameters.first)
    raise YARD::Parser::UndocumentableError, "Expected a symbol or string literal for first parameter but found '#{parameters.first.type}' at #{statement.file}:#{statement.line}." unless name
    name
  end

  def find_docstring(node, kind)
    # Walk the tree searching for assignments or calls to desc/doc=
    node.traverse do |child|
      if child.type == :assign
        ivar = child.jump(:ivar)
        next unless ivar != child && ivar.source == '@doc'
        docstring = node_as_string(child[1])
        log.error "Failed to parse docstring for #{kind} near #{child.file}:#{child.line}." and return nil unless docstring
        return PuppetStrings::Yard::Util.scrub_string(docstring)
      elsif child.is_a?(YARD::Parser::Ruby::MethodCallNode)
        # Look for a call to a dispatch method with a block
        next unless child.method_name &&
                    (child.method_name.source == 'desc' || child.method_name.source == 'doc=') &&
                    child.parameters(false).count == 1

        docstring = node_as_string(child.parameters[0])
        log.error "Failed to parse docstring for #{kind} near #{child.file}:#{child.line}." and return nil unless docstring
        return PuppetStrings::Yard::Util.scrub_string(docstring)
      end
    end
    log.warn "Missing a description for #{kind} at #{node.file}:#{node.line}."
    nil
  end

  def populate_type_data(object)
    # Traverse the block looking for properties/parameters/features
    block = statement.block
    return unless block && block.count >= 2
    block[1].children.each do |node|
      next unless node.is_a?(YARD::Parser::Ruby::MethodCallNode) &&
                  node.method_name

      method_name = node.method_name.source
      parameters = node.parameters(false)

      if method_name == 'newproperty'
        # Add a property to the object
        next unless parameters.count >= 1
        name = node_as_string(parameters[0])
        next unless name
        object.add_property(create_property(name, node))
      elsif method_name == 'newparam'
        # Add a parameter to the object
        next unless parameters.count >= 1
        name = node_as_string(parameters[0])
        next unless name
        object.add_parameter(create_parameter(name, node))
      elsif method_name == 'feature'
        # Add a feature to the object
        next unless parameters.count >= 2
        name = node_as_string(parameters[0])
        next unless name

        docstring = node_as_string(parameters[1])
        next unless docstring

        object.add_feature(PuppetStrings::Yard::CodeObjects::Type::Feature.new(name, docstring))
      elsif method_name == 'ensurable'
        if node.block
          property = create_property('ensure', node)
          property.docstring = DEFAULT_ENSURABLE_DOCSTRING if property.docstring.empty?
        else
          property = PuppetStrings::Yard::CodeObjects::Type::Property.new('ensure', DEFAULT_ENSURABLE_DOCSTRING)
          property.add('present')
          property.add('absent')
          property.default = 'present'
        end
        object.add_property property
      end
    end
  end

  def create_parameter(name, node)
    parameter = PuppetStrings::Yard::CodeObjects::Type::Parameter.new(name, find_docstring(node, "Puppet resource parameter '#{name}'"))
    set_values(node, parameter)
    parameter
  end

  def create_property(name, node)
    property = PuppetStrings::Yard::CodeObjects::Type::Property.new(name, find_docstring(node, "Puppet resource property '#{name}'"))
    set_values(node, property)
    property
  end

  def set_values(node, object)
    return unless node.block && node.block.count >= 2

    node.block[1].children.each do |child|
      next unless child.is_a?(YARD::Parser::Ruby::MethodCallNode) && child.method_name

      method_name = child.method_name.source
      parameters = child.parameters(false)

      if method_name == 'newvalue'
        next unless parameters.count >= 1
        object.add(node_as_string(parameters[0]) || parameters[0].source)
      elsif method_name == 'newvalues'
        parameters.each do |p|
          object.add(node_as_string(p) || p.source)
        end
      elsif method_name == 'aliasvalue'
        next unless parameters.count >= 2
        object.alias(node_as_string(parameters[0]) || parameters[0].source, node_as_string(parameters[1]) || parameters[1].source)
      elsif method_name == 'defaultto'
        next unless parameters.count >= 1
        object.default = node_as_string(parameters[0]) || parameters[0].source
      elsif method_name == 'isnamevar'
        object.isnamevar = true
      elsif method_name == 'defaultvalues' && object.name == 'ensure'
        object.add('present')
        object.add('absent')
        object.default = 'present'
      end
    end
    if object.is_a? PuppetStrings::Yard::CodeObjects::Type::Parameter
      # Process the options for parameter base types
      parameters = node.parameters(false)
      if parameters.count >= 2
        parameters[1].each do |kvp|
          next unless kvp.count == 2
          next unless node_as_string(kvp[0]) == 'parent'
          if kvp[1].source == 'Puppet::Parameter::Boolean'
            object.add('true') unless object.values.include? 'true'
            object.add('false') unless object.values.include? 'false'
            object.add('yes') unless object.values.include? 'yes'
            object.add('no') unless object.values.include? 'no'
          end
          break
        end
      end
    end
  end

  def set_default_namevar(object)
    return unless object.properties || object.parameters
    default = nil
    if object.properties
      object.properties.each do |property|
        return nil if property.isnamevar
        default = property if property.name == 'name'
      end
    end
    if object.parameters
      object.parameters.each do |parameter|
        return nil if parameter.isnamevar
        default ||= parameter if parameter.name == 'name'
      end
    end
    default.isnamevar = true if default
  end
end
