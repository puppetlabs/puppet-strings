require 'puppet-strings/yard/code_objects'

# Implements a parameter directive (e.g. #@!puppet.type.property) for documenting Puppet resource types.
class PuppetStrings::Yard::Tags::PropertyDirective < YARD::Tags::Directive
  # Called to invoke the directive.
  # @return [void]
  def call
    return unless object && object.respond_to?(:add_property)
    # Add a property to the resource
    property = PuppetStrings::Yard::CodeObjects::Type::Property.new(tag.name, tag.text)
    if tag.types
      tag.types.each do |value|
        property.add(value)
      end
    end
    object.add_property property
  end

  # Registers the directive with YARD.
  # @return [void]
  def self.register!
    YARD::Tags::Library.define_directive('puppet.type.property', :with_types_and_name, self)
  end
end
