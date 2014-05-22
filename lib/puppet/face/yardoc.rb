require 'puppet/face'
require 'puppetx/yardoc/util'

Puppet::Face.define(:yardoc, '0.0.1') do

  action(:yardoc) do
    default

    when_invoked do |manifest, options|

      unless Puppet.features.yard?
        raise RuntimeError, "The 'yard' gem must be installed in order to use this face."
      end

      if Puppet.features.rgen?
        require 'puppet/pops'
      else
        raise RuntimeError, "The 'rgen' gem must be installed in order to use this face."
      end

      parser = Puppet::Pops::Parser::Parser.new()
      parse_result = parser.parse_file(manifest)

      commentor = Puppetx::Yardoc::Commentor.new()

      return commentor.get_comments(parse_result)
    end
  end
end
