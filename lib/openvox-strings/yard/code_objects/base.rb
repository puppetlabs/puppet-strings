# frozen_string_literal: true

# Implements the base code object.
class OpenvoxStrings::Yard::CodeObjects::Base < YARD::CodeObjects::NamespaceObject
  # Allocates a new code object.
  # @param [Array] args The arguments to initialize the code object with.
  # @return Returns the code object.
  def self.new(*)
    # Skip the super class' implementation because it detects :: in names and this will cause namespaces in the output we don't want
    object = Object.class.instance_method(:new).bind_call(self, *)
    existing = YARD::Registry.at(object.path)
    object = existing if existing.instance_of?(self)
    yield(object) if block_given?
    object
  end
end
