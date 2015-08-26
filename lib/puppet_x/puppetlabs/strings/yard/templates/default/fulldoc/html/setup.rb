def generate_class_list
  @items = options.objects.select{|o| [:module, :class, :root].include? o.type} if options.objects
  @list_title = "Class List"
  @list_type = "class"
  generate_list_contents
end

def generate_puppet_manifest_list
  @items = options.objects.select{|o| [:hostclass, :definedtype].include? o.type} if options.objects
  @list_title = "Puppet Manifest List"
  # This is important. It causes some YARD JavaScript bits to hook in and
  # perform the correct formatting.
  @list_class = "class"
  @list_type = "puppet_manifest"
  generate_list_contents
end

def generate_puppet_plugin_list
  # NOTE: PuppetNamaspaceObject might eventually be used for more than just a
  # container for plugins...
  @items = options.objects.select{|o| [:puppetnamespace].include? o.type} if options.objects
  @list_title = "Puppet Plugin List"
  # This is important. It causes some YARD JavaScript bits to hook in and
  # perform the correct formatting.
  @list_class = "class"
  @list_type = "puppet_plugin"
  generate_list_contents
end

def generate_puppet_type_list
  @items = options.objects.select{|o| [:type].include? o.type} if options.objects
  @list_title = "Puppet Type List"
  @list_type = "puppet_type"
  generate_list_contents
end

def generate_puppet_provider_list
  @items = options.objects.select{|o| [:provider].include? o.type} if options.objects
  @list_title = "Puppet Provider List"
  @list_type = "puppet_provider"
  generate_list_contents
end



# A hacked version of class_list that can be instructed to only display certain
# namespace types. This allows us to separate Puppet bits from Ruby bits.
def namespace_list(opts = {})
  o = {
    :root => Registry.root,
    :namespace_types => [:module, :class]
  }.merge(opts)

  root = o[:root]
  namespace_types = o[:namespace_types]

  out = ""
  children = run_verifier(root.children)
  if root == Registry.root
    children += @items.select {|o| o.namespace.is_a?(CodeObjects::Proxy) }
  end
  children.reject {|c| c.nil? }.sort_by {|child| child.path }.map do |child|
    if namespace_types.include? child.type
      name = child.namespace.is_a?(CodeObjects::Proxy) ? child.path : child.name
      has_children = child.respond_to?(:children) && run_verifier(child.children).any? {|o| o.is_a?(CodeObjects::NamespaceObject) }
      out << "<li>"
      out << "<a class='toggle'></a> " if has_children
      out << linkify(child, name)
      out << " &lt; #{child.superclass.name}" if child.is_a?(CodeObjects::ClassObject) && child.superclass
      out << "<small class='search_info'>"
      out << child.namespace.title
      out << "</small>"
      out << "</li>"
      out << "<ul>#{namespace_list(:root => child, :namespace_types => namespace_types)}</ul>" if has_children
    end
  end
  out
end
