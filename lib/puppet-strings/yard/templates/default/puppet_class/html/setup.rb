# Initializes the template.
# @return [void]
def init
  sections :header, :box_info, :summary, :overview, :note, :todo, T('tags'), :source
end

# Renders the box_info section.
# @return [String] Returns the rendered section.
def box_info
  @subclasses = Registry.all(:puppet_class).find_all { |c|
    c.statement.parent_class == object.name.to_s
  }
  erb(:box_info)
end
