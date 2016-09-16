require 'mocha'
require 'rspec'
require 'puppet-strings'
require 'puppet-strings/yard'

# Explicitly set up YARD once
PuppetStrings::Yard.setup!

RSpec.configure do |config|
  config.mock_with :mocha

  config.before(:each) do
    # Always clear the YARD registry before each example
    YARD::Registry.clear
  end
end

