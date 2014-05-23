require 'puppet/face'
require 'puppetx/yardoc/yard/parser'

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

      parser = Puppetx::Yardoc::YARD::PuppetParser.new(File.read(manifest), manifest)
      parser.parse

      return parser.enumerator
    end
  end
end
