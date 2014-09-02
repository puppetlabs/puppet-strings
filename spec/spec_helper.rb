dir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift File.join(dir, 'lib')

require 'mocha'
require 'puppet'
require 'rspec'

# This is neeeded so we can access a Registry if YARD creates one
require 'puppetx/yardoc/yard/plugin'
include YARD

RSpec.configure do |config|
    config.mock_with :mocha
end

# Borrowed from YARD spec helper
def parse_file(file, thisfile = __FILE__, log_level = log.level, ext = '.pp')
  Registry.clear
  path = File.join(File.dirname(thisfile), 'examples', file.to_s + ext)
  YARD::Parser::SourceParser.parse(path, [], log_level)
end

