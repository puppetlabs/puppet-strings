require 'puppet/pops'

require_relative 'puppet_namespace_object'

module Puppetx::PuppetLabs::Strings::YARD::CodeObjects
  class DefinedTypeObject < PuppetNamespaceObject
    # A list of parameters attached to this class.
    # @return [Array<Array(String, String)>]
    attr_accessor :parameters
  end
end
