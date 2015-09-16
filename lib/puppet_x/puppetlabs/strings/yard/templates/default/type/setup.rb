include T('default/module')

require File.join(File.dirname(__FILE__),'../html_helper')
require File.join(File.dirname(__FILE__),'../template_helper')

def init
  sections :header, :box_info, :pre_docstring, :docstring, :parameter_details, :provider_details

  @template_helper = TemplateHelper.new
  @html_helper = HTMLHelper.new
end

def header
  @header_text = object.header_name

  erb(:header)
end

def provider_details
  type_name = object.name.to_s
  @providers = YARD::Registry.all(:provider).select { |t| t.type_name == type_name }

  erb(:provider_details)
end

def parameter_details
  params = object.parameter_details.map { |h| h[:name] }
  # Put properties and parameters in one big list where the descriptions are
  # scrubbed and htmlified and the namevar is the first element, the ensure
  # property the second, and the rest are alphabetized.
  @param_details = (object.parameter_details + object.property_details).each {
    |h| h[:desc] = htmlify(Puppet::Util::Docs::scrub(h[:desc])) if h[:desc]
  }.sort { |a, b| a[:name] <=> b[:name] }
  # Float ensurable and namevars to the top of the list
  @param_details = @param_details.partition{|a| a[:name] == 'ensure'}.flatten
  @param_details = @param_details.partition{|a| a[:namevar]}.flatten

  @feature_details = object.features
  @template_helper.check_parameters_match_docs object

  erb(:parameter_details)
end

def header
  @header_text = "Puppet Type: #{object.name}"

  erb(:header)
end

def docstring

  @class_details = @template_helper.extract_tag_data(object)

  erb(:docstring)
end
