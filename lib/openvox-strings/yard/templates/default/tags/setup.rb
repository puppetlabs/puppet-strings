# frozen_string_literal: true

# Called to return parameter tags.
# @return [Array<YARD::Tag>] Returns the parameter tags if the object should have parameters.
def param
  tag(:param) if
    %i[method puppet_class puppet_data_type puppet_defined_type puppet_function puppet_task puppet_plan].include?(object.type)
end

# Renders the overload section.
# @return [String] Returns the rendered section.
def overload
  erb((object.type == :puppet_function) ? :puppet_overload : :overload)
end

# Renders the enum section.
# @return [String] Returns the rendered section.
def enum
  erb(:enum)
end
