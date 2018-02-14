if ENV['COVERAGE'] == 'yes'
  require 'simplecov'
  require 'simplecov-console'
  require 'codecov'

  SimpleCov.formatters = [
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::Console,
    SimpleCov::Formatter::Codecov,
  ]
  SimpleCov.start do
    track_files 'lib/**/*.rb'

    add_filter '/spec'
  end
end

require 'mocha'
require 'rspec'
require 'puppet/version'
require 'puppet-strings'
require 'puppet-strings/yard'

# Explicitly set up YARD once
PuppetStrings::Yard.setup!

# Enable testing of Puppet functions if running against 4.1+
TEST_PUPPET_FUNCTIONS = Gem::Dependency.new('', '>= 4.1.0').match?('', Puppet::PUPPETVERSION)

# Enable testing of Puppet language functions declared with return type if running against 4.8+
TEST_FUNCTION_RETURN_TYPE = Gem::Dependency.new('', '>= 4.8.0').match?('', Puppet::PUPPETVERSION)

RSpec.configure do |config|
  config.mock_with :mocha

  config.before(:each) do
    # Always clear the YARD registry before each example
    YARD::Registry.clear
  end
end
