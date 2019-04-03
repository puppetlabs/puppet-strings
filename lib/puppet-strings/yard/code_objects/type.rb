require 'puppet-strings/yard/code_objects/group'
require 'puppet-strings/yard/util'

# Implements the group for Puppet resource types.
class PuppetStrings::Yard::CodeObjects::Types < PuppetStrings::Yard::CodeObjects::Group
  # Gets the singleton instance of the group.
  # @return Returns the singleton instance of the group.
  def self.instance
    super(:puppet_types)
  end

  # Gets the display name of the group.
  # @param [Boolean] prefix whether to show a prefix. Ignored for Puppet group namespaces.
  # @return [String] Returns the display name of the group.
  def name(prefix = false)
    'Resource Types'
  end
end

# Implements the Puppet resource type code object.
class PuppetStrings::Yard::CodeObjects::Type < PuppetStrings::Yard::CodeObjects::Base
  # Represents a resource type parameter.
  class Parameter
    attr_reader :name, :values, :aliases
    attr_accessor :docstring, :isnamevar, :default, :data_type, :required_features

    # Initializes a resource type parameter or property.
    # @param [String] name The name of the parameter or property.
    # @param [String] docstring The docstring for the parameter or property.s
    def initialize(name, docstring = nil)
      @name = name
      @docstring = docstring || ''
      @values = []
      @data_type = []
      @aliases = {}
      @isnamevar = false
      @default = nil
    end

    # Adds a value to the parameter or property.
    # @param [String] value The value to add.
    # @return [void]
    def add(value)
      @values << value
    end

    # Aliases a value to another value.
    # @param [String] new The new (alias) value.
    # @param [String] old The old (existing) value.
    # @return [void]
    def alias(new, old)
      @values << new unless @values.include? new
      @aliases[new] = old
    end

    # Converts the parameter to a hash representation.
    # @return [Hash] Returns a hash representation of the parameter.
    def to_hash
      hash = {}
      hash[:name] = name
      hash[:description] = docstring unless docstring.empty?
      hash[:values] = values unless values.empty?
      hash[:data_type] = data_type unless data_type.empty?
      hash[:aliases] = aliases unless aliases.empty?
      hash[:isnamevar] = true if isnamevar
      hash[:required_features] = required_features if required_features
      hash[:default] = default if default
      hash
    end
  end

  # Represents a resource type property (same attributes as a parameter).
  class Property < Parameter
  end

  # Represents a resource type feature.
  class Feature
    attr_reader :name, :docstring

    # Initializes a new feature.
    # @param [String] name The name of the feature.
    # @param [String] docstring The docstring of the feature.
    def initialize(name, docstring)
      @name = name
      @docstring = PuppetStrings::Yard::Util.scrub_string(docstring).gsub("\n", ' ')
    end

    # Converts the feature to a hash representation.
    # @return [Hash] Returns a hash representation of the feature.
    def to_hash
      hash = {}
      hash[:name] = name
      hash[:description] = docstring unless docstring.empty?
      hash
    end
  end

  attr_reader :properties, :parameters, :features

  # Initializes a new resource type.
  # @param [String] name The resource type name.
  # @return [void]
  def initialize(name)
    super(PuppetStrings::Yard::CodeObjects::Types.instance, name)
  end

  # Gets the type of the code object.
  # @return Returns the type of the code object.
  def type
    :puppet_type
  end

  # Adds a parameter to the resource type
  # @param [PuppetStrings::Yard::CodeObjects::Type::Parameter] parameter The parameter to add.
  # @return [void]
  def add_parameter(parameter)
    @parameters ||= []
    @parameters << parameter
  end

  # Adds a property to the resource type
  # @param [PuppetStrings::Yard::CodeObjects::Type::Property] property The property to add.
  # @return [void]
  def add_property(property)
    @properties ||= []
    @properties << property
  end

  # Adds a feature to the resource type.
  # @param [PuppetStrings::Yard::CodeObjects::Type::Feature] feature The feature to add.
  # @return [void]
  def add_feature(feature)
    @features ||= []
    @features << feature
  end

  # Converts the code object to a hash representation.
  # @return [Hash] Returns a hash representation of the code object.
  def to_hash
    hash = {}
    hash[:name] = name
    hash[:file] = file
    hash[:line] = line
    hash[:docstring] = PuppetStrings::Yard::Util.docstring_to_hash(docstring)
    hash[:properties] = properties.map(&:to_hash) if properties && !properties.empty?
    hash[:parameters] = parameters.map(&:to_hash) if parameters && !parameters.empty?
    hash[:features] = features.map(&:to_hash) if features && !features.empty?
    hash
  end
end
