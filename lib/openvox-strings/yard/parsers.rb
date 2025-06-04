# frozen_string_literal: true

# The module for custom YARD parsers.
module OpenvoxStrings::Yard::Parsers
  # The module for custom YARD parsers for JSON.
  module JSON
    require 'openvox-strings/yard/parsers/json/parser'
  end

  # The module for custom YARD parsers for the Puppet language.
  module Puppet
    require 'openvox-strings/yard/parsers/puppet/parser'
  end
end
