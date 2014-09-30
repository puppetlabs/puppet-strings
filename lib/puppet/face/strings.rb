require 'puppet/face'

Puppet::Face.define(:strings, '0.0.1') do
  summary "Generate Puppet documentation with YARD."

  # Ensures that the user has the needed features to use puppet strings
  def check_required_features
    unless Puppet.features.yard?
      raise RuntimeError, "The 'yard' gem must be installed in order to use this face."
    end

    unless Puppet.features.rgen?
      raise RuntimeError, "The 'rgen' gem must be installed in order to use this face."
    end

    if RUBY_VERSION.match(/^1\.8/)
      raise RuntimeError, "This face requires Ruby 1.9 or greater."
    end
  end

  # A list of globs that generates the default list of module files from which
  # documentation can be extracted.
  #
  # TODO: It would be awesome if we could somehow override/append to the
  # default file list that YARD uses. Consider an upstream PR for this.
  MODULE_SOURCEFILES = ['manifests/**/*.pp', 'lib/**/*.rb']

  action(:yardoc) do
    default

    summary "Generate YARD documentation from files."
    arguments "[manifest_file.pp ...]"

    when_invoked do |*args|
      check_required_features
      require 'puppetx/puppetlabs/strings/actions'

      yardoc_actions = Puppetx::PuppetLabs::Strings::Actions.new(Puppet[:debug], Puppet[:trace])

      # The last element of the argument array should be the options hash.
      #
      # NOTE: The Puppet Face will throw 'unrecognized option' errors if any
      # YARD options are passed to it. The best way to approach this problem is
      # by using the `.yardopts` file. YARD will autoload any options placed in
      # that file.
      opts = args.pop

      # For now, assume the remaining positional args are a list of manifest
      # and ruby files to parse.
      yard_args = (args.empty? ? MODULE_SOURCEFILES : args)

      yardoc_actions.generate_documentation(*yard_args)
    end
  end

  # NOTE: Modeled after the `yard gems` command which builds doc indicies
  # (.yardoc directories) for Ruby Gems. Currently lacks the fine-grained
  # control over where these indicies are created and just dumps them in the
  # module roots.

  action(:server) do
    summary "Serve YARD documentation for modules."

    when_invoked do |*args|
      check_required_features
      require 'puppetx/puppetlabs/strings/actions'

      server_actions = Puppetx::PuppetLabs::Strings::Actions.new(Puppet[:debug], Puppet[:trace])

      opts = args.pop

      module_names = args

      # FIXME: This is pretty inefficient as it forcibly re-generates the YARD
      # indicies each time the server is started. However, it ensures things are
      # generated properly.
      module_list = server_actions.index_documentation_for_modules(module_names, MODULE_SOURCEFILES)

      module_tuples = server_actions.generate_module_tuples(module_list)

      module_tuples.map! do |mod|
        [mod[:name], mod[:index_path]]
      end

      # The `-m` flag means a list of name/path pairs will follow. The name is
      # used as the module name and the path indicates which `.yardoc` index to
      # generate documentation from.
      yard_args = %w[-m -q] + module_tuples.flatten
      merge_puppet_args!(yard_args)

      server_actions.serve_documentation(*yard_args)
    end
  end
end

