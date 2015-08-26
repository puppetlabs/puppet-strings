include T('default/module')

require File.join(File.dirname(__FILE__),'../html_helper')
require File.join(File.dirname(__FILE__),'../template_helper')

def init
  sections :header, :box_info, :pre_docstring, :docstring, :command_details, :confine_details, :default_details, :feature_details

  @template_helper = TemplateHelper.new
  @html_helper = HTMLHelper.new
end

def command_details
  @command_details = object.commands
  erb(:command_details)
end

def confine_details
  @confine_details = object.confines
  erb(:confine_details)
end

def default_details
  @default_details = object.defaults
  erb(:default_details)
end

def feature_details
  @feature_details = object.features
  erb(:feature_details)
end

def header
  @header_text = "Puppet Provider: #{object.name}"

  erb(:header)
end

def docstring

  @class_details = @template_helper.extract_tag_data(object)

  erb(:docstring)
end
