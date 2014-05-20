require 'puppet/face'

Puppet::Face.define(:yardoc, '0.0.1') do

  action(:yardoc) do
    default

    when_invoked do |*args|

      unless Puppet.features.yard?
        raise RuntimeError, "The 'yard' gem must be installed in order to use this face."
      end

      if Puppet.features.rgen?
        require 'puppet/pops'
      else
        raise RuntimeError, "The 'rgen' gem must be installed in order to use this face."
      end

      parser = Puppet::Pops::Parser::Parser.new()
      parse_result = parser.parse_file(args[0])

      return 0
    end
  end
end
