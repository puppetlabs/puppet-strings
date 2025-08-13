# frozen_string_literal: true

require 'openvox-strings/yard/code_objects/group'
require 'openvox-strings/yard/util'

# Implements the group for Puppet DataTypes.
class OpenvoxStrings::Yard::CodeObjects::DataTypes < OpenvoxStrings::Yard::CodeObjects::Group
  # Gets the singleton instance of the group.
  # @return Returns the singleton instance of the group.
  def self.instance
    super(:puppet_data_types)
  end

  # Gets the display name of the group.
  # @param [Boolean] prefix whether to show a prefix. Ignored for Puppet group namespaces.
  # @return [String] Returns the display name of the group.
  def name(_prefix = false)
    'Puppet Data Types'
  end
end

# Implements the Puppet DataType code object.
class OpenvoxStrings::Yard::CodeObjects::DataType < OpenvoxStrings::Yard::CodeObjects::Base
  # Initializes a Puppet class code object.
  # @param [String] The name of the Data Type
  # @return [void]
  def initialize(name)
    super(OpenvoxStrings::Yard::CodeObjects::DataTypes.instance, name)
    @defaults = {}
  end

  # Gets the type of the code object.
  # @return Returns the type of the code object.
  def type
    :puppet_data_type
  end

  # Gets the source of the code object.
  # @return Returns the source of the code object.
  def source
    # Not implemented, but would be nice!
    nil
  end

  def add_parameter(name, type, default)
    tag = docstring.tags(:param).find { |item| item.name == name }
    if tag.nil?
      tag = YARD::Tags::Tag.new(:param, '', nil, name)
      docstring.add_tag(tag)
    end
    type = [type] unless type.is_a?(Array)
    tag.types = type if tag.types.nil?
    set_parameter_default(name, default)
  end

  def set_parameter_default(param_name, default)
    defaults.delete(param_name)
    defaults[param_name] = default unless default.nil?
  end

  def parameters
    docstring.tags(:param).map { |tag| [tag.name, defaults[tag.name]] }
  end

  def add_function(name, return_type, parameter_types)
    meth_obj = YARD::CodeObjects::MethodObject.new(self, name, :class)

    # Add return tag
    meth_obj.add_tag(YARD::Tags::Tag.new(:return, '', return_type))

    # Add parameters
    parameter_types.each_with_index do |param_type, index|
      meth_obj.add_tag(YARD::Tags::Tag.new(:param, '', [param_type], "param#{index + 1}"))
    end

    meths << meth_obj
  end

  def functions
    meths
  end

  # Converts the code object to a hash representation.
  # @return [Hash] Returns a hash representation of the code object.
  def to_hash
    hash = {}
    hash[:name] = name
    hash[:file] = file
    hash[:line] = line
    hash[:docstring] = OpenvoxStrings::Yard::Util.docstring_to_hash(docstring, %i[param option enum return example])
    hash[:defaults] = defaults unless defaults.nil? || defaults.empty?
    hash[:source] = source unless source.nil? || source.empty?
    hash[:functions] = functions.map do |func|
      {
        name: func.name,
        signature: func.signature,
        docstring: OpenvoxStrings::Yard::Util.docstring_to_hash(func.docstring, %i[param option enum return example]),
      }
    end
    hash
  end
end
