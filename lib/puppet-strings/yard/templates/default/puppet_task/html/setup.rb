# Initializes the template.
# @return [void]
def init
  sections :header, :box_info, T('tags'), :overview, :input, :parameters
end

def json
  object.statement.json
end

def description
  json['description']
end

# Renders the parameters section.
# @return [String] Returns the rendered section.
def parameters
  @parameters = json['parameters'] || []
  @parameters.to_a.sort!
  @tag_title = 'Parameters'
  erb(:parameters)
end
