# frozen_string_literal: true

# Initializes the template.
# @return [void]
def init
  case object
  when '_index.html'
    @page_title = options.title
    sections :layout, [:index, [:listing, %i[classes data_types defined_types types providers functions tasks plans files objects]]]
  else
    super
  end
end

# Renders the layout section.
# @return [String] Returns the rendered section.
def layout
  @nav_url = url_for_list((!@file || options.index) ? menu_lists.first[:type] : 'file')

  case object
  when nil, String
    @path = nil
  when @file
    @path = @file.path
  when !object.is_a?(YARD::CodeObjects::NamespaceObject)
    @path = object.parent.path
    @nav_url = url_for_list('class')
  when YARD::CodeObjects::ClassObject
    @path = object.path
    @nav_url = url_for_list('class')
  when OpenvoxStrings::Yard::CodeObjects::Class
    @nav_url = url_for_list('puppet_class')
    @page_title = "Puppet Class: #{object.name}"
    @path = object.path
  when OpenvoxStrings::Yard::CodeObjects::DataType, OpenvoxStrings::Yard::CodeObjects::DataTypeAlias
    @nav_url = url_for_list('puppet_data_type')
    @page_title = "Data Type: #{object.name}"
    @path = object.path
  when OpenvoxStrings::Yard::CodeObjects::DefinedType
    @nav_url = url_for_list('puppet_defined_type')
    @page_title = "Defined Type: #{object.name}"
    @path = object.path
  when OpenvoxStrings::Yard::CodeObjects::Type
    @nav_url = url_for_list('puppet_type')
    @page_title = "Resource Type: #{object.name}"
    @path = object.path
  when OpenvoxStrings::Yard::CodeObjects::Provider
    @nav_url = url_for_list('puppet_provider')
    @page_title = "Provider: #{object.name}"
    @path = object.path
  when OpenvoxStrings::Yard::CodeObjects::Function
    @nav_url = url_for_list('puppet_function')
    @page_title = "Puppet Function: #{object.name} (#{object.function_type})"
    @path = object.path
  when OpenvoxStrings::Yard::CodeObjects::Task
    @nav_url = url_for_list('puppet_task')
    @page_title = "Puppet Task: #{object.name}"
    @path = object.path
  when OpenvoxStrings::Yard::CodeObjects::Plan
    @nav_url = url_for_list('puppet_plan')
    @page_title = "Puppet Plan: #{object.name}"
    @path = object.path
  else
    @path = object.path
  end

  final_layout = erb(:layout)

  OpenvoxStrings::Yard::Util.github_to_yard_links(final_layout) if @file && @file.name == 'README'

  final_layout
end

# Creates the dynamic menu lists.
# @return [Array<Hash>] Returns the dynamic menu list.
def create_menu_lists
  menu_lists = [
    {
      type: 'puppet_class',
      title: 'Puppet Classes',
      search_title: 'Puppet Classes',
    },
    {
      type: 'puppet_data_type',
      title: 'Data Types',
      search_title: 'Data Types',
    },
    {
      type: 'puppet_defined_type',
      title: 'Defined Types',
      search_title: 'Defined Types',
    },
    {
      type: 'puppet_type',
      title: 'Resource Types',
      search_title: 'Resource Types',
    },
    {
      type: 'puppet_provider',
      title: 'Providers',
      search_title: 'Providers',
    },
    {
      type: 'puppet_function',
      title: 'Puppet Functions',
      search_title: 'Puppet Functions',
    },
    {
      type: 'puppet_task',
      title: 'Puppet Tasks',
      search_totle: 'Puppet Tasks',
    },
    {
      type: 'puppet_plan',
      title: 'Puppet Plans',
      search_totle: 'Puppet Plans',
    },
    {
      type: 'class',
      title: 'Ruby Classes',
      search_title: 'Class List',
    },
    {
      type: 'method',
      title: 'Ruby Methods',
      search_title: 'Method List',
    },
  ]

  menu_lists.delete_if { |e| YARD::Registry.all(e[:type].intern).empty? }

  # We must always return at least one group, so always keep the files list
  if menu_lists.empty? || !YARD::Registry.all(:file).empty?
    menu_lists << {
      type: 'file',
      title: 'Files',
      search_title: 'File List',
    }
  end

  menu_lists
end

# Gets the menu lists to use.
# @return [Array<Hash] Returns the menu lists to use.
def menu_lists
  @@lists ||= create_menu_lists.freeze
end

# Builds a list of objects by letter.
# @param [Array] types The types of objects to find.
# @return [Hash] Returns a hash of first letter of the object name to list of objects.
def objects_by_letter(*types)
  hash = {}
  objects = Registry.all(*types).sort_by { |o| o.name.to_s }
  objects = run_verifier(objects)
  objects.each { |o| (hash[o.name.to_s[0, 1].upcase] ||= []) << o }
  hash
end

# Renders the classes section.
# @return [String] Returns the rendered section.
def classes
  @title = 'Puppet Class Listing A-Z'
  @objects_by_letter = objects_by_letter(:puppet_class)
  erb(:objects)
end

# Renders the data types section.
# @return [String] Returns the rendered section.
def data_types
  @title = 'Data Type Listing A-Z'
  @objects_by_letter = objects_by_letter(:puppet_data_type, :puppet_data_type_alias)
  erb(:objects)
end

# Renders the defined types section.
# @return [String] Returns the rendered section.
def defined_types
  @title = 'Defined Type Listing A-Z'
  @objects_by_letter = objects_by_letter(:puppet_defined_type)
  erb(:objects)
end

# Renders the types section.
# @return [String] Returns the rendered section.
def types
  @title = 'Resource Type Listing A-Z'
  @objects_by_letter = objects_by_letter(:puppet_type)
  erb(:objects)
end

# Renders the providers section.
# @return [String] Returns the rendered section.
def providers
  @title = 'Puppet Provider Listing A-Z'
  @objects_by_letter = objects_by_letter(:puppet_provider)
  erb(:objects)
end

# Renders the functions section.
# @return [String] Returns the rendered section.
def functions
  @title = 'Puppet Function Listing A-Z'
  @objects_by_letter = objects_by_letter(:puppet_function)
  erb(:objects)
end

# Renders the tasks section.
# @return [String] Returns the rendered section.
def tasks
  @title = 'Puppet Task Listing A-Z'
  @objects_by_letter = objects_by_letter(:puppet_task)
  erb(:objects)
end

# Renders the plans section.
# @return [String] Returns the rendered section.
def plans
  @title = 'Puppet Plan Listing A-Z'
  @objects_by_letter = objects_by_letter(:puppet_plan)
  erb(:objects)
end

# Renders the objects section.
# @return [String] Returns the rendered section.
def objects
  @title = 'Ruby Namespace Listing A-Z'
  @objects_by_letter = objects_by_letter(:class, :module)
  erb(:objects)
end
