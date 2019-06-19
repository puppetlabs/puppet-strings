require 'puppet-strings/yard/code_objects/group'

class PuppetStrings::Yard::CodeObjects::Plans < PuppetStrings::Yard::CodeObjects::Group
  # Gets the singleton instance of the group.
  # @return Returns the singleton instance of the group.
  def self.instance
    super(:puppet_plans)
  end

  # Gets the display name of the group.
  # @param [Boolean] prefix whether to show a prefix. Ignored for Puppet group namespaces.
  # @return [String] Returns the display name of the group.
  def name(prefix = false)
    'Puppet Plans'
  end
end

class PuppetStrings::Yard::CodeObjects::Plan < PuppetStrings::Yard::CodeObjects::Base
  attr_reader :statement
  attr_reader :parameters

  # Initializes a Puppet plan code object.
  # @param [PuppetStrings::Parsers::PlanStatement] statement The plan statement that was parsed.
  # @return [void]
  def initialize(statement)
    @statement = statement
    @parameters = statement.parameters.map { |p| [p.name, p.value] }
    super(PuppetStrings::Yard::CodeObjects::Plans.instance, statement.name)
  end

  # Gets the type of the code object.
  # @return Returns the type of the code object.
  def type
    :puppet_plan
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
    hash[:file] = file
    hash[:line] = line
    hash[:docstring] = PuppetStrings::Yard::Util.docstring_to_hash(docstring)
    defaults = Hash[*parameters.reject{ |p| p[1].nil? }.flatten]
    hash[:defaults] = defaults unless defaults.empty?
    hash[:source] = source unless source && source.empty?
    hash
  end
end
