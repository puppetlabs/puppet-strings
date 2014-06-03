require 'yard'
require 'puppet/pops'

require_relative '../../yardoc'
require_relative '../pops/yard_transformer'

module Puppetx::Yardoc::YARD
  class PuppetParser < YARD::Parser::Base
    attr_reader :file, :source

    def initialize(source, filename)
      @source = source
      @file = filename

      @parser = Puppet::Pops::Parser::Parser.new()
      @transformer = Puppetx::Yardoc::Pops::YARDTransformer.new()
    end

    def parse
      @parse_result ||= @parser.parse_string(source)
      self
    end

    def enumerator
      statements = @transformer.transform(@parse_result)

      # Ensure an array is returned and prune any nil values.
      Array(statements).compact
    end

  end
end
