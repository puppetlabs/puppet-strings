class PuppetX::PuppetLabs::Strings::YARD::Handlers::Base < YARD::Handlers::Base
  # Easy access to Pops model objects for handler matching.
  include Puppet::Pops::Model
  # Easy access to custom code objects from which documentation is generated.
  include PuppetX::PuppetLabs::Strings::YARD::CodeObjects

  def self.handles?(statement)
    handlers.any? {|h| h == statement.type}
  end

end
