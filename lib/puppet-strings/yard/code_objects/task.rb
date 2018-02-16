require 'puppet-strings/yard/code_objects/group'

# Implements the group for Puppet tasks.
class PuppetStrings::Yard::CodeObjects::Tasks < PuppetStrings::Yard::CodeObjects::Group
  # Gets the singleton instance of the group.
  # @return Returns the singleton instance of the group.
  def self.instance
    super(:puppet_tasks)
  end

  # Gets the display name of the group.
  # @param [Boolean] prefix whether to show a prefix. Ignored for Puppet group namespaces.
  # @return [String] Returns the display name of the group.
  def name(prefix = false)
    'Puppet Tasks'
  end
end

# Implements the Puppet task code object.
class PuppetStrings::Yard::CodeObjects::Task < PuppetStrings::Yard::CodeObjects::Base
  attr_reader :source

  # Initializes a Puppet task code object.
  # @param [PuppetStrings::Parsers::ClassStatement] statement The class statement that was parsed.
  # @return [void]
  def initialize(source)
    @source = source
    j = JSON.parse(source)
    @parameters = j['parameters'].map { |name,value| [p.name, p.value] }
    super(PuppetStrings::Yard::CodeObjects::Tasks.instance, statement.name)
  end

  # Gets the type of the code object.
  # @return Returns the type of the code object.
  def type
    :puppet_task
  end

  # Gets the source of the code object.
  # @return Returns the source of the code object.
  def source
    @statement.source
  end

  # Converts the code object to a hash representation.
  # @return [Hash] Returns a hash representation of the code object.
  def to_hash
    hash = {}
    hash[:name] = name
    hash[:docstring] = PuppetStrings::Json.docstring_to_hash(docstring)
    defaults = Hash[*parameters.select{ |p| !p[1].nil? }.flatten]
    hash[:defaults] = defaults unless defaults.empty?
    hash[:source] = source unless source && source.empty?
    hash
  end
end
