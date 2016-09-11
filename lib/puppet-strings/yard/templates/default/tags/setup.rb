# Called to return parameter tags.
# @return [Array<YARD::Tag>] Returns the parameter tags if the object should have parameters.
def param
  tag(:param) if
    object.type == :method ||
    object.type == :puppet_class ||
    object.type == :puppet_defined_type
end
