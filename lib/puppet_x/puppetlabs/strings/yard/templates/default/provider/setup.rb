include T('default/module')

require File.join(File.dirname(__FILE__),'../html_helper')
require File.join(File.dirname(__FILE__),'../template_helper')

def init
  sections :header, :box_info, :pre_docstring, :docstring, :parameter_details

  @template_helper = TemplateHelper.new
  @html_helper = HTMLHelper.new
end

def parameter_details
  params = object.parameter_details.map { |h| h[:name] }
  @param_details = object.parameter_details.each { |h| h[:desc] = htmlify(h[:desc]) }
  @template_helper.check_parameters_match_docs object

  erb(:parameter_details)
end

def header
  @header_text = "Puppet Provider: #{object.name}"

  erb(:header)
end

def docstring

  @class_details = @template_helper.extract_tag_data(object)

  erb(:docstring)
end
