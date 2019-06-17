require 'puppet-strings/yard/code_objects/group'
require 'puppet-strings/yard/util'

# Implements the group for Puppet DataTypes.
class PuppetStrings::Yard::CodeObjects::DataTypes < PuppetStrings::Yard::CodeObjects::Group
  # Gets the singleton instance of the group.
  # @return Returns the singleton instance of the group.
  def self.instance
    super(:puppet_data_types)
  end

  # Gets the display name of the group.
  # @param [Boolean] prefix whether to show a prefix. Ignored for Puppet group namespaces.
  # @return [String] Returns the display name of the group.
  def name(prefix = false)
    'Puppet Data Types'
  end
end

# Implements the Puppet DataType code object.
class PuppetStrings::Yard::CodeObjects::DataType < PuppetStrings::Yard::CodeObjects::Base
  # Initializes a Puppet class code object.
  # @param [String] The name of the Data Type
  # @return [void]
  def initialize(name)
    super(PuppetStrings::Yard::CodeObjects::DataTypes.instance, name)
    @parameters = []
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

  def parameter_exist?(name)
    !docstring.tags(:param).find { |item| item.name == name }.nil?
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

  # Converts the code object to a hash representation.
  # @return [Hash] Returns a hash representation of the code object.
  def to_hash
    hash = {}
    hash[:name] = name
    hash[:file] = file
    hash[:line] = line
    hash[:docstring] = PuppetStrings::Yard::Util.docstring_to_hash(docstring)
    hash[:defaults] = defaults unless defaults.empty?
    hash[:source] = source unless source && source.empty?
    hash
  end
end
