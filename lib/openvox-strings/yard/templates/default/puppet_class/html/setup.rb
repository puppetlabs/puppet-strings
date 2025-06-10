# frozen_string_literal: true

# Initializes the template.
# @return [void]
def init
  sections :header, :box_info, :summary, :overview, :note, :todo, :deprecated, T('tags'), :source
end

# Renders the box_info section.
# @return [String] Returns the rendered section.
def box_info
  @subclasses = Registry.all(:puppet_class).find_all do |c|
    c.statement.parent_class == object.name.to_s
  end
  erb(:box_info)
end
