# Initializes the template.
# @return [void]
def init
  sections :header, :box_info, :summary, :overview, :note, :todo, T('tags'), :properties, :parameters, :features
end

# Renders the box_info section.
# @return [String] Returns the rendered section.
def box_info
  @providers = PuppetStrings::Yard::CodeObjects::Providers.instance(object.name).children
  erb(:box_info)
end

# Renders the properties section.
# @return [String] Returns the rendered section.
def properties
  # Properties are the same thing as parameters (from the documentation standpoint),
  # so reuse the same template but with a different title and data source.
  @parameters = object.properties || []
  @parameters.sort_by! { |p| p.name }
  @tag_title = 'Properties'
  erb(:parameters)
end

# Renders the parameters section.
# @return [String] Returns the rendered section.
def parameters
  @parameters = object.parameters || []
  @parameters.sort_by! { |p| p.name }
  @tag_title = 'Parameters'
  erb(:parameters)
end
