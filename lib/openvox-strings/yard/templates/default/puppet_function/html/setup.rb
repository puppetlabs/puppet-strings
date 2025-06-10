# frozen_string_literal: true

# Initializes the template.
# @return [void]
def init
  sections :header, :box_info, :summary, :overview, [:note, :todo, :deprecated, T('tags'), :source]
end
