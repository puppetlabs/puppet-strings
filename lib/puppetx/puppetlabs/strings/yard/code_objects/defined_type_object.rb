require 'puppet/pops'

require 'puppetx/puppetlabs/strings/yard/code_objects/puppet_namespace_object'

class Puppetx::PuppetLabs::Strings::YARD::CodeObjects::DefinedTypeObject < Puppetx::PuppetLabs::Strings::YARD::CodeObjects::PuppetNamespaceObject
  # A list of parameters attached to this class.
  # @return [Array<Array(String, String)>]
  attr_accessor :parameters
end
