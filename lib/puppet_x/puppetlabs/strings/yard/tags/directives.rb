require 'puppet_x/puppetlabs/strings/yard/core_ext/yard'
# Creates a new code object based on the directive
class PuppetX::PuppetLabs::Strings::YARD::Tags::PuppetTypeParameterDirective < YARD::Tags::Directive
  def call
    return if object.nil?
    object.parameters << ([tag.text, tag.types].flatten)
    object.parameter_details << {:name => tag.name, :desc => tag.text, :exists? => true, :puppet_type => true}
  end
end
