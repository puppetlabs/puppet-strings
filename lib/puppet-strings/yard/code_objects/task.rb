require 'puppet-strings/yard/code_objects/group'

# Implements the group for Puppet tasks.
class PuppetStrings::Yard::CodeObjects::Tasks < PuppetStrings::Yard::CodeObjects::Group
  # Gets the singleton instance of the group.
  # @return Returns the singleton instance of the group.
  def self.instance
    super(:puppet_tasks)
  end

  # Gets the display name of the group.
  # @param [Boolean] prefix whether to show a prefix.
  # @return [String] Returns the display name of the group.
  def name(prefix = false)
    'Puppet Tasks'
  end
end

# Implements the Puppet task code object.
class PuppetStrings::Yard::CodeObjects::Task < PuppetStrings::Yard::CodeObjects::Base
  attr_reader :statement

  # Initializes a JSON task code object.
  # @param [String] source The task's JSON file source
  # @param [String] filepath Path to task's .json file
  # @return [void]
  def initialize(statement)
    @name = statement.name
    @statement = statement
    super(PuppetStrings::Yard::CodeObjects::Tasks.instance, name)
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

  # A task can't be undocumented, which is nice. Because of this,
  # just return a generic docstring for stats purposes.
  # @return [YARD::Docstring] generic docstring
  def docstring
    YARD::Docstring.new("Puppet Task docstring")
  end

  # Converts the code object to a hash representation.
  # @return [Hash] Returns a hash representation of the code object.
  def to_hash
    { name: name.to_s }.merge statement.json
  end
end
