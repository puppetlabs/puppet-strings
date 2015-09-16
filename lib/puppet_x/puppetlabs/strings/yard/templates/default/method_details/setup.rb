include T('default/module')
require File.join(File.dirname(__FILE__),'../html_helper')
require File.join(File.dirname(__FILE__),'../template_helper')

def init
  sections :header, [:method_signature, T('docstring'), :source]
  parents = YARD::Registry.all(:method).reject do |item|
    item.name == object.name and item.namespace === PuppetX::PuppetLabs::Strings::YARD::CodeObjects::PuppetNamespaceObject
  end
  if parents.length == 0
    @template_helper = TemplateHelper.new
    @template_helper.check_parameters_match_docs object
  end
end

def source
  return if owner != object.namespace
  return if Tags::OverloadTag === object
  return if object.source.nil?
  erb(:source)
end
