require 'puppet-strings/yard/handlers/helpers'
require 'puppet-strings/yard/handlers/ruby/type_base'
require 'puppet-strings/yard/code_objects'
require 'puppet-strings/yard/util'

# Implements the handler for Puppet resource types written in Ruby.
class PuppetStrings::Yard::Handlers::Ruby::TypeHandler < PuppetStrings::Yard::Handlers::Ruby::TypeBase
  # The default docstring when ensurable is used without given a docstring.
  DEFAULT_ENSURABLE_DOCSTRING = 'The basic property that the resource should be in.'.freeze

  namespace_only
  handles method_call(:newtype)

  process do
    # Only accept calls to Puppet::Type
    return unless statement.count > 1
    module_name = statement[0].source
    return unless module_name == 'Puppet::Type' || module_name == 'Type'

    object = get_type_yard_object(get_name(statement, 'Puppet::Type.newtype'))

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
end
