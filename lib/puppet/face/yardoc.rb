require 'puppet/face'

Puppet::Face.define(:yardoc, '0.0.1') do

  action(:yardoc) do
    default

    when_invoked do |*args|
      unless Puppet.features.yard?
        raise RuntimeError, "The 'yard' gem must be installed in order to use this face."
      end

      unless Puppet.features.rgen?
        raise RuntimeError, "The 'rgen' gem must be installed in order to use this face."
      end

      if RUBY_VERSION < '1.9' && !Puppet.features.require_relative?
        raise RuntimeError, "The 'backports' gem must be installed in order to use this face under Ruby 1.8.7."
      end

      # The last element of the argument array should be the options hash.
      #
      # NOTE: The Puppet Face will throw 'unrecognized option' errors if any
      # YARD options are passed to it. The best way to approach this problem is
      # by using the `.yardopts` file. YARD will autoload any options placed in
      # that file.
      opts = args.pop

      # For now, assume the remaining positional args are a list of manifest
      # files to parse.
      manifest_files = (args.empty? ? ['manifests/**/*.pp'] : args)

      require 'puppetx/yardoc/yard/plugin'

      # Hand off to YARD for further processing.
      YARD::CLI::Yardoc.run(*manifest_files)
    end
  end
end
