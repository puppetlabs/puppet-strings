# Generates the searchable Puppet class list.
# @return [void]
def generate_puppet_class_list
  @items = Registry.all(:puppet_class).sort_by { |c| c.name.to_s }
  @list_title = 'Puppet Class List'
  @list_type = 'puppet_class'
  generate_list_contents
end

# Generates the searchable Ruby method list.
# @return [void]
def generate_method_list
  @items = prune_method_listing(Registry.all(:method), false)
  @items = @items.reject {|m| m.name.to_s =~ /=$/ && m.is_attribute? }
  @items = @items.sort_by {|m| m.name.to_s }
  @list_title = 'Ruby Method List'
  @list_type = 'method'
  generate_list_contents
end

# Generate a searchable Ruby class list in the output.
# @return [void]
def generate_class_list
  @items = options.objects if options.objects
  @list_title = 'Ruby Class List'
  @list_type = 'class'
  generate_list_contents
end
