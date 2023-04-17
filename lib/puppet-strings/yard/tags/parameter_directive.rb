# frozen_string_literal: true

require 'puppet-strings/yard/code_objects'

# Implements a parameter directive (e.g. #@!puppet.type.param) for documenting Puppet resource types.
class PuppetStrings::Yard::Tags::ParameterDirective < YARD::Tags::Directive
  # Called to invoke the directive.
  # @return [void]
  def call
    return unless object.respond_to?(:add_parameter)

    # Add a parameter to the resource
    parameter = PuppetStrings::Yard::CodeObjects::Type::Parameter.new(tag.name, tag.text)
    tag.types&.each do |value|
      parameter.add(value)
    end
    object.add_parameter parameter
  end

  # Registers the directive with YARD.
  # @return [void]
  def self.register!
    YARD::Tags::Library.define_directive('puppet.type.param', :with_types_and_name, self)
  end
end
