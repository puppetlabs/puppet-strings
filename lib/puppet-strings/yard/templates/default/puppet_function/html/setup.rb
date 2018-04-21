# Initializes the template.
# @return [void]
def init
  sections :header, :box_info, :summary, :overview, :note, :todo, [T('tags'), :source]
end
