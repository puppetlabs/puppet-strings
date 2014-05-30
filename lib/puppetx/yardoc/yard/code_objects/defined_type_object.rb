require 'yard'
require 'puppet/pops'

require_relative '../../../yardoc'

module Puppetx::Yardoc::YARD::CodeObjects
  class DefinedTypeObject < YARD::CodeObjects::NamespaceObject
    # A list of parameters attached to this class.
    # @return [Array<Array(String, String)>]
    attr_accessor :parameters

    # The `YARD::Codeobjects::Base` class pulls a bunch of shenanigans to
    # insert proxy namespaces. Unfortunately, said shenanigans pick up on the
    # `::` in Puppet names and start to mangle things based on rules for the
    # Ruby language.
    #
    # Therefore, we must override `new` for great justice.
    #
    # TODO: Ask around on the YARD mailing list to see if there is a way around
    # this ugliness.
    #
    # Alternately, consider ensuring all `proxy` objects resolve to a
    # placeholder `NamespaceObject` as the name mangling behavior of these is
    # easier to control.
    def self.new(namespace, name, *args, &block)
      # Standard Ruby boilerplate for `new`
      obj = self.allocate
      obj.send :initialize, namespace, name, *args

      # The last bit of `YARD::CodeObjects::Base.new`.
      existing_obj = YARD::Registry.at(obj.path)
      obj = existing_obj if existing_obj && existing_obj.class == self
      yield(obj) if block_given?
      obj
    end
  end
end
