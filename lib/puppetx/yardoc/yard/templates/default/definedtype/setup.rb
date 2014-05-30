include T('default/module')

def init
  sections :header, :box_info, :pre_docstring, T('docstring'), :parameter_details
end

def parameter_details
  return if object.parameters.empty?
  erb(:parameter_details)
end
