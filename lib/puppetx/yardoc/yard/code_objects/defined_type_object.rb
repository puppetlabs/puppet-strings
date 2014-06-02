require 'yard'
require 'puppet/pops'

require_relative '../../../yardoc'

module Puppetx::Yardoc::YARD::CodeObjects
  class DefinedTypeObject < YARD::CodeObjects::NamespaceObject
    # A list of parameters attached to this class.
    # @return [Array<Array(String, String)>]
    attr_accessor :parameters

    # FIXME: We used to override `self.new` to ensure no YARD proxies were
    # created for namespaces segments that did not map to a host class or
    # defined type. Fighting the system in this way turned out to be
    # counter-productive.
    #
    # However, if a proxy is left in, YARD will drop back to namspace-mangling
    # heuristics that are very specific to Ruby and which produce ugly paths in
    # the resulting output. Consider walking the namespace tree for each new
    # class/type and ensuring that a placeholder other than a YARD proxy is
    # used.
    #
    # def self.new(namespace, name, *args, &block)
  end
end
