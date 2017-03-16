# Initializes the template.
# @return [void]
def init
  sections :header, :box_info, :summary, :overview, T('tags'), :features, :confines, :defaults, :commands
end

# Renders the confines section.
# @return [String] Returns the rendered section.
def confines
  @title = 'Confines'
  @collection = object.confines
  erb(:collection)
end

# Renders the defaults section.
# @return [String] Returns the rendered section.
def defaults
  @title = 'Default Provider For'
  @collection = object.defaults
  erb(:collection)
end

# Renders the commands section.
# @return [String] Returns the rendered section.
def commands
  @title = 'Commands'
  @collection = object.commands
  erb(:collection)
end
