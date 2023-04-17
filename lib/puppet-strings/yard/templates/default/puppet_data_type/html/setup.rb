# frozen_string_literal: true

# Initializes the template.
# @return [void]
def init
  sections :header, :box_info, :summary, :overview, :note, :todo, :deprecated, T('tags'), :method_details_list, [T('method_details')], :source
end

def method_listing
  sort_listing(object.functions)
end

def sort_listing(list)
  list.sort_by { |o| [o.scope.to_s, o.name.to_s.downcase] }
end
