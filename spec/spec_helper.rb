dir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift File.join(dir, 'lib')

require 'mocha'
require 'puppet'
require 'rspec'

# This is neeeded so we can access a Registry if YARD creates one
require 'puppetx/puppetlabs/strings/yard/plugin'
include YARD

RSpec.configure do |config|
    config.mock_with :mocha
end

