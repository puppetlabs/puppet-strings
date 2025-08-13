# frozen_string_literal: true

require 'openvox-strings/yard/code_objects/group'
require 'openvox-strings/yard/util'

# Implements the group for Puppet resource types.
class OpenvoxStrings::Yard::CodeObjects::Types < OpenvoxStrings::Yard::CodeObjects::Group
  # Gets the singleton instance of the group.
  # @return Returns the singleton instance of the group.
  def self.instance
    super(:puppet_types)
  end

  # Gets the display name of the group.
  # @param [Boolean] prefix whether to show a prefix. Ignored for Puppet group namespaces.
  # @return [String] Returns the display name of the group.
  def name(_prefix = false)
    'Resource Types'
  end
end

# Implements the Puppet resource type code object.
class OpenvoxStrings::Yard::CodeObjects::Type < OpenvoxStrings::Yard::CodeObjects::Base
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

  class Check < Parameter
  end

  # Represents a resource type feature.
  class Feature
    attr_reader :name, :docstring

    # Initializes a new feature.
    # @param [String] name The name of the feature.
    # @param [String] docstring The docstring of the feature.
    def initialize(name, docstring)
      @name = name
      @docstring = OpenvoxStrings::Yard::Util.scrub_string(docstring).tr("\n", ' ')
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

  attr_reader :properties, :features, :checks

  # Initializes a new resource type.
  # @param [String] name The resource type name.
  # @return [void]
  def initialize(name)
    super(OpenvoxStrings::Yard::CodeObjects::Types.instance, name)
  end

  # Gets the type of the code object.
  # @return Returns the type of the code object.
  def type
    :puppet_type
  end

  # Adds a parameter to the resource type
  # @param [OpenvoxStrings::Yard::CodeObjects::Type::Parameter] parameter The parameter to add.
  # @return [void]
  def add_parameter(parameter)
    @parameters ||= []
    @parameters << parameter
  end

  # Adds a property to the resource type
  # @param [OpenvoxStrings::Yard::CodeObjects::Type::Property] property The property to add.
  # @return [void]
  def add_property(property)
    @properties ||= []
    @properties << property
  end

  # Adds a feature to the resource type.
  # @param [OpenvoxStrings::Yard::CodeObjects::Type::Feature] feature The feature to add.
  # @return [void]
  def add_feature(feature)
    @features ||= []
    @features << feature
  end

  # Adds a check to the resource type.
  # @param [OpenvoxStrings::Yard::CodeObjects::Type::Check] check The check to add.
  # @return [void]
  def add_check(check)
    @checks ||= []
    @checks << check
  end

  def parameters
    @parameters ||= [] # guard against not filled parameters
    # just return params if there are no providers
    return @parameters if providers.empty?

    # return existing params if we have already added provider
    return @parameters if @parameters&.any? { |p| p.name == 'provider' }

    provider_param = Parameter.new(
      'provider',
      "The specific backend to use for this `#{name}` resource. You will seldom need " \
      'to specify this --- Puppet will usually discover the appropriate provider for your platform.',
    )

    @parameters ||= []
    @parameters << provider_param
  end

  # Not sure if this is where this belongs or if providers should only be resolved at
  # render-time. For now, this should re-resolve on every call.
  # may be able to memoize this
  def providers
    providers = YARD::Registry.all(:"puppet_providers_#{name}")
    return providers if providers.empty?

    providers.first.children
  end

  # Converts the code object to a hash representation.
  # @return [Hash] Returns a hash representation of the code object.
  def to_hash
    hash = {}

    hash[:name] = name
    hash[:file] = file
    hash[:line] = line

    hash[:docstring]  = OpenvoxStrings::Yard::Util.docstring_to_hash(docstring)
    hash[:properties] = properties.sort_by(&:name).map(&:to_hash) if properties && !properties.empty?
    hash[:parameters] = parameters.sort_by(&:name).map(&:to_hash) if parameters && !parameters.empty?
    hash[:checks]     = checks.sort_by(&:name).map(&:to_hash) if checks && !checks.empty?
    hash[:features]   = features.sort_by(&:name).map(&:to_hash) if features && !features.empty?
    hash[:providers]  = providers.sort_by(&:name).map(&:to_hash) if providers && !providers.empty?

    hash
  end
end
