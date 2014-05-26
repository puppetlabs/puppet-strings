require 'yard'
require 'puppet/pops'

require_relative '../../../yardoc'
require_relative '../code_objects'

module Puppetx::Yardoc::YARD::Handlers
  class Base < YARD::Handlers::Base
    # Easy access to Pops model objects for handler matching.
    include Puppet::Pops::Model
    # Easy access to custom code objects from which documentation is generated.
    include Puppetx::Yardoc::YARD::CodeObjects

    def self.handles?(statement)
      handlers.any? {|h| h == statement.type}
    end

  end
end
