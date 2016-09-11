require 'puppet-strings/yard/code_objects/base'

# Implements the base class for "groups".
#
# A group behaves like a YARD namespace object, but displays differently in the HTML output.
class PuppetStrings::Yard::CodeObjects::Group < PuppetStrings::Yard::CodeObjects::Base
  # Gets the singleton instance of the group.
  # @param [Symbol] key The key to lookup the group for.
  # @return Returns the singleton instance of the group.
  def self.instance(key)
    instance = P(:root, key)
    return instance unless instance.is_a?(YARD::CodeObjects::Proxy)
    instance = self.new(:root, key)
    instance.visibility = :hidden
    P(:root).children << instance
    instance
  end

  # Gets the path to the group.
  # @return [String] Returns the path to the group.
  def path
    @name.to_s
  end

  # Gets the type of the group.
  # @return [Symbol] Returns the type of the group.
  def type
    @name
  end
end
