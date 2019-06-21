require 'puppet-strings/yard/code_objects/group'
require 'puppet-strings/yard/util'

# Implements the group for Puppet DataTypeAliases.
class PuppetStrings::Yard::CodeObjects::DataTypeAliases < PuppetStrings::Yard::CodeObjects::Group
  # Gets the singleton instance of the group.
  # @return Returns the singleton instance of the group.
  def self.instance
    super(:puppet_data_type_aliases)
  end

  # Gets the display name of the group.
  # @param [Boolean] prefix whether to show a prefix. Ignored for Puppet group namespaces.
  # @return [String] Returns the display name of the group.
  def name(prefix = false)
    'Puppet Data Type Aliases'
  end
end

# Implements the Puppet DataTypeAlias code object.
class PuppetStrings::Yard::CodeObjects::DataTypeAlias < PuppetStrings::Yard::CodeObjects::Base
  attr_reader :statement
  attr_accessor :alias_of

  # Initializes a Puppet data type alias code object.
  # @param [PuppetStrings::Parsers::DataTypeAliasStatement] statement The data type alias statement that was parsed.
  # @return [void]
  def initialize(statement)
    @statement = statement
    @alias_of = statement.alias_of
    super(PuppetStrings::Yard::CodeObjects::DataTypeAliases.instance, statement.name)
  end

  # Gets the type of the code object.
  # @return Returns the type of the code object.
  def type
    :puppet_data_type_alias
  end

  # Gets the source of the code object.
  # @return Returns the source of the code object.
  def source
    # Not implemented, but would be nice!
    nil
  end

  # Converts the code object to a hash representation.
  # @return [Hash] Returns a hash representation of the code object.
  def to_hash
    hash = {}
    hash[:name] = name
    hash[:file] = file
    hash[:line] = line
    hash[:docstring] = PuppetStrings::Yard::Util.docstring_to_hash(docstring)
    hash[:alias_of] = alias_of
    hash
  end
end
