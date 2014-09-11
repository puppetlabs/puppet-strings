require 'yard'
require 'puppet/pops'

require_relative '../../../strings'
require_relative '../code_objects'

module Puppetx::Strings::YARD::Handlers
  class Base < YARD::Handlers::Base
    # Easy access to Pops model objects for handler matching.
    include Puppet::Pops::Model
    # Easy access to custom code objects from which documentation is generated.
    include Puppetx::Strings::YARD::CodeObjects

    def self.handles?(statement)
      handlers.any? {|h| h == statement.type}
    end

  end
end
