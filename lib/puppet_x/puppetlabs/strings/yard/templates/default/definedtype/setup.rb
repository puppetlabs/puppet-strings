include T('default/module')

require File.join(File.dirname(__FILE__),'../html_helper')
require File.join(File.dirname(__FILE__),'../template_helper')

def init
  sections :header, :box_info, :pre_docstring, :docstring, :parameter_details

  @template_helper = TemplateHelper.new
  @html_helper = HTMLHelper.new
end

def parameter_details
  return if object.parameters.empty?

  param_tags = object.tags.find_all{ |tag| tag.tag_name == "param"}
  params = object.parameters

  @param_details = []

  @param_details = @template_helper.extract_param_details(params, param_tags, object.files, true)

  erb(:parameter_details)
end

def header
  if object.type == :hostclass
    @header_text = "Puppet Class: #{object.name}"
  elsif object.type == :definedtype
    @header_text = "Puppet Defined Type: #{object.name}"
  else
    @header_text = "#{object.name}"
  end

  erb(:header)
end

def docstring

  @class_details = @template_helper.extract_tag_data(object)

  erb(:docstring)
end
