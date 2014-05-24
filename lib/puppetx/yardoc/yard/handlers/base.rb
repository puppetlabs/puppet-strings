require 'yard'
require 'puppet/pops'

require_relative '../../../yardoc'

module Puppetx::Yardoc::YARD::Handlers
  class Base < YARD::Handlers::Base
    include Puppet::Pops::Model # This allows handlers to match based on model classes.

    def self.handles?(statement)
      handlers.any? {|h| h == statement.type}
    end

  end
end
