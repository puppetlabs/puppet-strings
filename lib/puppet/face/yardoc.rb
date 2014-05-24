require 'puppet/face'

Puppet::Face.define(:yardoc, '0.0.1') do

  action(:yardoc) do
    default

    when_invoked do |manifest, options|

      unless Puppet.features.yard?
        raise RuntimeError, "The 'yard' gem must be installed in order to use this face."
      end

      unless Puppet.features.rgen?
        raise RuntimeError, "The 'rgen' gem must be installed in order to use this face."
      end

      require 'puppetx/yardoc/yard/plugin'

      parser = Puppetx::Yardoc::YARD::PuppetParser.new(File.read(manifest), manifest)
      parser.parse

      return parser.enumerator.map {|s| s.comments}
    end
  end
end
