require 'puppet-strings/yard/code_objects/group'

# Implements the group for Puppet functions.
class PuppetStrings::Yard::CodeObjects::Functions < PuppetStrings::Yard::CodeObjects::Group
  # Gets the singleton instance of the group.
  # @param [Symbol] type The function type to get the group for.
  # @return Returns the singleton instance of the group.
  def self.instance(type)
    super("puppet_functions_#{type}".intern)
  end

  # Gets the display name of the group.
  # @param [Boolean] prefix whether to show a prefix. Ignored for Puppet group namespaces.
  # @return [String] Returns the display name of the group.
  def name(prefix = false)
    'Puppet Functions'
  end
end

# Implements the Puppet function code object.
class PuppetStrings::Yard::CodeObjects::Function < PuppetStrings::Yard::CodeObjects::Base
  # Identifier for 3.x Ruby API functions
  RUBY_3X = :ruby3x
  # Identifier for 4.x Ruby API functions
  RUBY_4X = :ruby4x
  # Identifier for Puppet language functions
  PUPPET = :puppet

  attr_accessor :parameters

  # Initializes a Puppet function code object.
  # @param [String] name The name of the function.
  # @param [Symbol] function_type The type of function (e.g. :ruby3x, :ruby4x, :puppet)
  # @return [void]
  def initialize(name, function_type)
    super(PuppetStrings::Yard::CodeObjects::Functions.instance(function_type), name)
    @parameters = []
    @function_type = function_type
  end

  # Gets the type of the code object.
  # @return Returns the type of the code object.
  def type
    :puppet_function
  end

  # Gets the function type display string.
  # @return Returns the function type display string.
  def function_type
    case @function_type
    when RUBY_3X
      'Ruby 3.x API'
    when RUBY_4X
      'Ruby 4.x API'
    else
      'Puppet Language'
    end
  end

  # Gets the Puppet signature of the function (single overload only).
  # @return [String] Returns the Puppet signature of the function.
  def signature
    return '' if self.has_tag? :overload
    tags = self.tags(:param)
    args = @parameters.map do |parameter|
      name, default = parameter
      tag = tags.find { |t| t.name == name } if tags
      type = tag && tag.types ? "#{tag.type} " : 'Any '
      prefix = "#{name[0]}" if name.start_with?('*', '&')
      name = name[1..-1] if prefix
      default = " = #{default}" if default
      "#{type}#{prefix}$#{name}#{default}"
    end.join(', ')
    @name.to_s + '(' + args + ')'
  end

  # Converts the code object to a hash representation.
  # @return [Hash] Returns a hash representation of the code object.
  def to_hash
    hash = {}

    hash[:name] = name
    hash[:file] = file
    hash[:line] = line
    hash[:type] = @function_type.to_s
    hash[:signatures] = []

    if self.has_tag? :overload
      # loop over overloads and append onto the signatures array
      self.tags(:overload).each do |o|
        hash[:signatures] << { :signature => o.signature, :docstring => PuppetStrings::Yard::Util.docstring_to_hash(o.docstring, %i[param option enum return example]) }
      end
    else
      hash[:signatures] << { :signature => self.signature, :docstring =>  PuppetStrings::Yard::Util.docstring_to_hash(docstring, %i[param option enum return example]) }
    end

    hash[:docstring] = PuppetStrings::Yard::Util.docstring_to_hash(docstring)
    defaults = Hash[*parameters.reject{ |p| p[1].nil? }.flatten]
    hash[:defaults] = defaults unless defaults.empty?
    hash[:source] = source unless source && source.empty?
    hash
  end
end
