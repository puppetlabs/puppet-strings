dir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift File.join(dir, 'lib')

require 'mocha'
require 'puppet'
require 'rspec'

require 'puppet_x/puppetlabs/strings'

RSpec.configure do |config|
    config.mock_with :mocha
end

