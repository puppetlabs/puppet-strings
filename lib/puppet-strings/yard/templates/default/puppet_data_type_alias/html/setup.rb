# Initializes the template.
# @return [void]
def init
  sections :header, :box_info, :summary, :overview, :alias_of, :note, :todo, T('tags'), :source
end

# Renders the alias_of section.
# @return [String] Returns the rendered section.
def alias_of
  # Properties are the same thing as parameters (from the documentation standpoint),
  # so reuse the same template but with a different title and data source.
  #@parameters = object.properties || []
  #@parameters.sort_by! { |p| p.name }
  @tag_title = 'Alias of'
  @alias_of = object.alias_of
  erb(:alias_of)
end
