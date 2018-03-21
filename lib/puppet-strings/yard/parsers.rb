# The module for custom YARD parsers.
module PuppetStrings::Yard::Parsers
  # The module for custom YARD parsers for JSON.
  module JSON
    require 'puppet-strings/yard/parsers/json/parser'
  end
  # The module for custom YARD parsers for the Puppet language.
  module Puppet
    require 'puppet-strings/yard/parsers/puppet/parser'
  end
end
