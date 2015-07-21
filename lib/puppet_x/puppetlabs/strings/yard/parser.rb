require 'yard'
require 'puppet/pops'

require 'puppet_x/puppetlabs/strings'
require 'puppet_x/puppetlabs/strings//pops/yard_transformer'

class PuppetX::PuppetLabs::Strings::YARD::PuppetParser < YARD::Parser::Base
  attr_reader :file, :source

  def initialize(source, filename)
    @source = source
    @file = filename

    @parser = Puppet::Pops::Parser::Parser.new()
    @transformer = PuppetX::PuppetLabs::Strings::Pops::YARDTransformer.new()
  end

  def parse
    @parse_result ||= @parser.parse_string(source)
    self
  end

  def enumerator
    statements = @transformer.transform(@parse_result)

    # Ensure an array is returned and prune any nil values.
    Array(statements).compact.reverse
  end

end
