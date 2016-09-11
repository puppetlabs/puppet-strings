# Initializes the template.
# @return [void]
def init
  case object
  when '_index.html'
    @page_title = options.title
    sections :layout, [:index, [:listing, [:classes, :files, :objects]]]
  else
    super
  end
end

# Renders the layout section.
# @return [String] Returns the rendered section.
def layout
  @nav_url = url_for_list(!@file || options.index ? menu_lists.first[:type] : 'file')

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
  when PuppetStrings::Yard::CodeObjects::Class
    @nav_url = url_for_list('puppet_class')
    @page_title = "Puppet Class: #{object.name}"
    @path = object.path
  else
    @path = object.path
  end

  erb(:layout)
end

# Creates the dynamic menu lists.
# @return [Array<Hash>] Returns the dynamic menu list.
def create_menu_lists
  menu_lists = [
    {
      type: 'puppet_class',
      title: 'Puppet Classes',
      search_title: 'Puppet Classes'
    },
    {
      type: 'class',
      title: 'Ruby Classes',
      search_title: 'Class List'
    },
    {
      type: 'method',
      title: 'Ruby Methods',
      search_title: 'Method List'
    },
  ]

  menu_lists.delete_if { |e| YARD::Registry.all(e[:type].intern).empty? }

  # We must always return at least one group, so always keep the files list
  menu_lists << {
    type: 'file',
    title: 'Files',
    search_title: 'File List'
  } if menu_lists.empty? || !YARD::Registry.all(:file).empty?

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
  objects = Registry.all(*types).sort_by {|o| o.name.to_s }
  objects = run_verifier(objects)
  objects.each {|o| (hash[o.name.to_s[0,1].upcase] ||= []) << o }
  hash
end

# Renders the classes section.
# @return [String] Returns the rendered section.
def classes
  @title = 'Puppet Class Listing A-Z'
  @objects_by_letter = objects_by_letter(:puppet_class)
  erb(:objects)
end

# Renders the objects section.
# @return [String] Returns the rendered section.
def objects
  @title = 'Ruby Namespace Listing A-Z'
  @objects_by_letter = objects_by_letter(:class, :module)
  erb(:objects)
end
