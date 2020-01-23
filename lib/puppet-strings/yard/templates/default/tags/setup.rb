# Called to return parameter tags.
# @return [Array<YARD::Tag>] Returns the parameter tags if the object should have parameters.
def param
  tag(:param) if
    object.type == :method ||
    object.type == :puppet_class ||
    object.type == :puppet_data_type ||
    object.type == :puppet_defined_type ||
    object.type == :puppet_function ||
    object.type == :puppet_task ||
    object.type == :puppet_plan
end

# Renders the overload section.
# @return [String] Returns the rendered section.
def overload
  erb(if object.type == :puppet_function then :puppet_overload else :overload end)
end

# Renders the enum section.
# @return [String] Returns the rendered section.
def enum
  erb(:enum)
end
