require 'puppet/face'
require 'puppet/pops'

Puppet::Face.define(:yardoc, '0.0.1') do

  action(:yardoc) do
    default

    when_invoked do |*args|
      parser = Puppet::Pops::Parser::Parser.new()
      parse_result = parser.parse_file(args[0])

      return 0
    end
  end
end
