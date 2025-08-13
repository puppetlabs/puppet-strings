# frozen_string_literal: true

# Implements an overload tag for Puppet functions
#
# This differs from Yard's overload tag in that the signatures are formatted according to Puppet language rules.
class OpenvoxStrings::Yard::Tags::OverloadTag < YARD::Tags::Tag
  attr_reader :parameters, :docstring

  # Initializes the overload tag.
  # @param [String, Symbol] name The name of the function being overloaded.
  # @param [String] docstring The docstring for the overload.
  # @return [void]
  def initialize(name, docstring)
    super(:overload, nil)
    @name = name.to_s
    @parameters = []
    @docstring = YARD::Docstring.new(docstring)
  end

  # Gets the signature of the overload.
  # @return [String] Returns the signature of the overload.
  def signature
    tags = self.tags(:param)
    args = @parameters.map do |parameter|
      name, default = parameter
      tag = tags.find { |t| t.name == name } if tags
      type = tag&.types ? "#{tag.type} " : 'Any '
      prefix = name[0].to_s if name.start_with?('*', '&')
      name = name[1..] if prefix
      default = " = #{default}" if default
      "#{type}#{prefix}$#{name}#{default}"
    end.join(', ')
    "#{@name}(#{args})"
  end

  # Adds a tag to the overload's docstring.
  # @param [YARD::Tag] tag The tag to add to the overload's docstring.
  # @return [void]
  def add_tag(tag)
    @docstring.add_tag(tag)
  end

  # Gets the first tag of the given name.
  # @param [String, Symbol] name The name of the tag.
  # @return [YARD::Tag] Returns the first tag if found or nil if not found.
  def tag(name)
    @docstring.tag(name)
  end

  # Gets all tags or tags of a given name.
  # @param [String, Symbol] name The name of the tag to get or nil for all tags.
  # @return [Array<Yard::Tag>] Returns an array of tags.
  def tags(name = nil)
    @docstring.tags(name)
  end

  # Determines if a tag with the given name is present.
  # @param [String, Symbol] name The tag name.
  # @return [Boolean] Returns true if there is at least one tag with the given name or false if not.
  def has_tag?(name) # rubocop:disable Naming/PredicateName
    @docstring.has_tag?(name)
  end

  # Sets the object associated with this tag.
  # @param [Object] value The object to associate with this tag.
  # @return [void]
  def object=(value)
    super
    @docstring.object = value
    @docstring.tags.each { |tag| tag.object = value }
  end

  # Responsible for forwarding method calls to the associated object.
  # @param [Symbol] method_name The method being invoked.
  # @param [Array] args The args passed to the method.
  # @param block The block passed to the method.
  # @return Returns what the method call on the object would return.
  def method_missing(method_name, ...)
    return object.send(method_name, ...) if object.respond_to? method_name

    super
  end

  # Determines if the associated object responds to the give missing method name.
  # @param [Symbol, String] method_name The name of the method to check.
  # @param [Boolean] include_all True to include all methods in the check or false for only public methods.
  # @return [Boolean] Returns true if the object responds to the method or false if not.
  def respond_to_missing?(method_name, include_all = false)
    object.respond_to?(method_name, include_all) || super
  end

  # Gets the type of the object associated with this tag.
  # @return [Symbol] Returns the type of the object associated with this tag.
  def type
    object.type
  end

  # Converts the overload tag to a hash representation.
  # @return [Hash] Returns a hash representation of the overload.
  def to_hash
    hash = {}
    hash[:tag_name] = tag_name
    hash[:text] = text if text
    hash[:signature] = signature
    hash[:docstring] = OpenvoxStrings::Yard::Util.docstring_to_hash(docstring) unless docstring.blank?
    defaults = Hash[*parameters.reject { |p| p[1].nil? }.flatten]
    hash[:defaults] = defaults unless defaults.empty?
    hash[:types] = types if types
    hash[:name] = name if name
    hash
  end
end
