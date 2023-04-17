# frozen_string_literal: true

# Initializes the template.
# @return [void]
def init
  sections :header, :box_info, :summary, :overview, :note, :todo, :deprecated, T('tags'), :source
end

# Renders the box_info section.
# @return [String] Returns the rendered section.
def box_info
  erb(:box_info)
end
