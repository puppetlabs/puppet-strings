require 'puppet'

module Puppet::Parser::Functions
  newfunction(:puppet3_function, :type => rvalue) do |args|
    puts 'Hello World!'
  end
end
