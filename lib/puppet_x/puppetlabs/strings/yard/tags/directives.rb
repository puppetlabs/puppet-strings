require 'puppet_x/puppetlabs/strings/yard/core_ext/yard'
# Creates a new code object based on the directive
class PuppetX::PuppetLabs::Strings::YARD::Tags::PuppetProviderParameterDirective < YARD::Tags::Directive
  def call
    return if object.nil?
    object.parameters << ([tag.text] + tag.types)
    object.parameter_details << {:name => tag.name, :desc => tag.text, :exists? => true, :provider => true}
  end
end
