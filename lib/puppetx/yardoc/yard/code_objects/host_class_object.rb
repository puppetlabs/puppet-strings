require 'yard'
require 'puppet/pops'

require_relative '../../../yardoc'

module Puppetx::Yardoc::YARD::CodeObjects
  class HostClassObject < YARD::CodeObjects::NamespaceObject
    # The {HostClassObject} that this class inherits from, if any.
    # @return [HostClassObject, Proxy, nil]
    attr_accessor :parent_class

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

    def inheritance_tree
      if parent_class.is_a?(HostClassObject)
        # Cool. We got a host class. Return self + parent inheritance tree.
        [self] + parent_class.inheritance_tree
      elsif parent_class.is_a?(YARD::CodeObjects::Proxy)
        # We have a reference to a parent that has not been created yet. Just
        # return it.
        [self, parent_class]
      else
        # Most likely no parent class. But also possibly an object that we
        # shouldn't inherit from. Just return self.
        [self]
      end
    end
  end
end
