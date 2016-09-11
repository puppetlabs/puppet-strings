require 'puppet-strings/yard/code_objects/group'

# Implements the group for Puppet providers.
class PuppetStrings::Yard::CodeObjects::Providers < PuppetStrings::Yard::CodeObjects::Group
  # Gets the singleton instance of the group.
  # @param [String] type The resource type name for the provider.
  # @return Returns the singleton instance of the group.
  def self.instance(type)
    super("puppet_providers_#{type}".intern)
  end

  # Gets the display name of the group.
  # @param [Boolean] prefix whether to show a prefix. Ignored for Puppet group namespaces.
  # @return [String] Returns the display name of the group.
  def name(prefix = false)
    'Providers'
  end
end

# Implements the Puppet provider code object.
class PuppetStrings::Yard::CodeObjects::Provider < PuppetStrings::Yard::CodeObjects::Base
  attr_reader :type_name, :confines, :features, :defaults, :commands

  # Initializes a Puppet provider code object.
  # @param [String] type_name The resource type name for the provider.
  # @param [String] name The name of the provider.s
  # @return [void]
  def initialize(type_name, name)
    @type_name = type_name
    super(PuppetStrings::Yard::CodeObjects::Providers.instance(type_name), name)
  end

  # Gets the type of the code object.
  # @return Returns the type of the code object.
  def type
    :puppet_provider
  end

  # Adds a confine to the provider.
  # @param [String] key The confine's key.
  # @param [String] value The confine's value.
  # @return [void]
  def add_confine(key, value)
    return unless key && value
    @confines ||= {}
    @confines[key] = value
  end

  # Adds a feature to the provider.
  # @param [String] feature The feature to add to the provider.
  # @return [void]
  def add_feature(feature)
    return unless feature
    @features ||= []
    @features << feature
  end

  # Adds a default to the provider.
  # @param [String] key The default's key.
  # @param [String] value The default's value.
  # @return [void]
  def add_default(key, value)
    return unless key && value
    @defaults ||= {}
    @defaults[key] = value
  end

  # Adds a command to the provider.
  # @param [String] key The command's key.
  # @param [String] value The command's value.
  # @return [void]
  def add_command(key, value)
    return unless key && value
    @commands ||= {}
    @commands[key] = value
  end
end
