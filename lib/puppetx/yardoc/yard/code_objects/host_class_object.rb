require_relative 'defined_type_object'

module Puppetx::Yardoc::YARD::CodeObjects
  class HostClassObject < DefinedTypeObject
    # The {HostClassObject} that this class inherits from, if any.
    # @return [HostClassObject, Proxy, nil]
    attr_accessor :parent_class

    # NOTE: `include_mods` is never used as it makes no sense for Puppet, but
    # this is called by `YARD::Registry` and it will pass a parameter.
    def inheritance_tree(include_mods = false)
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
