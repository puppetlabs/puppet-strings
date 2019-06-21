# Generates the searchable Puppet class list.
# @return [void]
def generate_puppet_class_list
  @items = Registry.all(:puppet_class).sort_by { |c| c.name.to_s }
  @list_title = 'Puppet Class List'
  @list_type = 'puppet_class'
  generate_list_contents
end

# Generates the searchable Puppet data type list.
# @return [void]
def generate_puppet_data_type_list
  @items = Registry.all(:puppet_data_type, :puppet_data_type_alias).sort_by {|dt| dt.name.to_s }
  @list_title = 'Data Type List'
  @list_type = 'puppet_data_type'
  generate_list_contents
end

# Generates the searchable Puppet defined type list.
# @return [void]
def generate_puppet_defined_type_list
  @items = Registry.all(:puppet_defined_type).sort_by {|dt| dt.name.to_s }
  @list_title = 'Defined Type List'
  @list_type = 'puppet_defined_type'
  generate_list_contents
end

# Generates the searchable Puppet resource type list.
# @return [void]
def generate_puppet_type_list
  @items = Registry.all(:puppet_type).sort_by {|t| t.name.to_s }
  @list_title = 'Resource Type List'
  @list_type = 'puppet_type'
  generate_list_contents
end

# Generates the searchable Puppet provider list.
# @return [void]
def generate_puppet_provider_list
  @items = Registry.all(:puppet_provider).sort_by {|p| p.name.to_s }
  @list_title = 'Provider List'
  @list_type = 'puppet_provider'
  generate_list_contents
end

# Generates the searchable Puppet function list.
# @return [void]
def generate_puppet_function_list
  @items = Registry.all(:puppet_function).sort_by {|f| f.name.to_s }
  @list_title = 'Puppet Function List'
  @list_type = 'puppet_function'
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

# Generates the searchable Puppet Task list.
# @return [void]
def generate_puppet_task_list
  @items = Registry.all(:puppet_task).sort_by {|t| t.name.to_s }
  @list_title = 'Puppet Task List'
  @list_type = 'puppet_task'
  generate_list_contents
end

# Generates the searchable Puppet Plan list.
# @return [void]
def generate_puppet_plan_list
  @items = Registry.all(:puppet_plan).sort_by {|t| t.name.to_s }
  @list_title = 'Puppet Plan List'
  @list_type = 'puppet_plan'
  generate_list_contents
end
