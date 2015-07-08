class PuppetX::PuppetLabs::Strings::YARD::CodeObjects::PuppetNamespaceObject < YARD::CodeObjects::NamespaceObject
  # NOTE: `YARD::Registry#resolve` requires a method with this signature to
  # be present on all subclasses of `NamespaceObject`.
  def inheritance_tree(include_mods = false)
    [self]
  end

  attr_accessor :type_info

  # FIXME: We used to override `self.new` to ensure no YARD proxies were
  # created for namespaces segments that did not map to a host class or
  # defined type. Fighting the system in this way turned out to be
  # counter-productive.
  #
  # However, if a proxy is left in, YARD will drop back to namspace-mangling
  # heuristics that are very specific to Ruby and which produce ugly paths in
  # the resulting output. Need to find a way to address this.
  #
  # Tried:
  #
  #   - Overriding self.new in the code object. Failed because self.new
  #     overrides are gross and difficult to pull off. Especially when
  #     replacing an existing override.
  #
  #   - Adding functionality to the base handler to ensure something other
  #     than a proxy occupies each namespace segment. Failed because once a
  #     code object is created with a namespace, it will never update.
  #     Unless that namespace is set to a Proxy.
  #
  # def self.new(namespace, name, *args, &block)
end

