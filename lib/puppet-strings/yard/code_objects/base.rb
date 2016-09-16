# Implements the base code object.
class PuppetStrings::Yard::CodeObjects::Base < YARD::CodeObjects::NamespaceObject
  # Allocates a new code object.
  # @param [Array] args The arguments to initialize the code object with.
  # @return Returns the code object.
  def self.new(*args)
    # Skip the super class' implementation because it detects :: in names and this will cause namespaces in the output we don't want
    object = Object.class.instance_method(:new).bind(self).call(*args)
    existing = YARD::Registry.at(object.path)
    object = existing if existing && existing.class == self
    yield(object) if block_given?
    object
  end
end
