# Initializes the template.
# @return [void]
def init
  sections :header, :box_info, :summary, :overview, T('tags'), :source
end

# Renders the box_info section.
# @return [String] Returns the rendered section.
def box_info
  erb(:box_info)
end
