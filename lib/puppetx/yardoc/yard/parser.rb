require 'puppetx/yardoc'

require 'yard'
require 'puppet/pops'
require 'puppetx/yardoc/pops/yard_transformer'

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
      @transformer.transform(@parse_result)
    end

  end
end
