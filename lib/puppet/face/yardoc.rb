require 'puppet/face'

Puppet::Face.define(:yardoc, '0.0.1') do
  summary "Generate Puppet documentation with YARD."

  def check_required_features
    unless Puppet.features.yard?
      raise RuntimeError, "The 'yard' gem must be installed in order to use this face."
    end

    unless Puppet.features.rgen?
      raise RuntimeError, "The 'rgen' gem must be installed in order to use this face."
    end

    if RUBY_VERSION < '1.9' && !Puppet.features.require_relative?
      raise RuntimeError, "The 'backports' gem must be installed in order to use this face under Ruby 1.8.7."
    end
  end

  # Maps things like the Puppet `--debug` flag to YARD options.
  def merge_puppet_args!(yard_args)
    yard_args.unshift '--debug'     if Puppet[:debug]
    yard_args.unshift '--backtrace' if Puppet[:trace]

    yard_args
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
      merge_puppet_args!(yard_args)

      require 'puppetx/yardoc/yard/plugin'

      # Hand off to YARD for further processing.
      YARD::CLI::Yardoc.run(*yard_args)
    end
  end

  # NOTE: Modeled after the `yard gems` command which builds doc indicies
  # (.yardoc directories) for Ruby Gems. Currently lacks the fine-grained
  # control over where these indicies are created and just dumps them in the
  # module roots.
  action(:modules) do
    summary "Generate YARD indices for a list of modules."
    arguments "[module-name ...]"

    when_invoked do |*args|
      check_required_features
      require 'puppetx/yardoc/yard/plugin'
      opts = args.pop

      # NOTE: The retrun value of the `module` Face seems to have changed in
      # 3.6.x. This part of the code will blow up if run under an earlier
      # version of Puppet.
      modules = Puppet::Face[:module, :current].list
      module_list = modules[:modules_by_path].values.flatten

      # TODO: Can use select! if Ruby 1.8.7 support is dropped.
      module_list = module_list.select {|m| args.include? m.name} unless args.empty?

      # Invoke `yardoc` with -n so that it doesn't generate any HTML output but
      # does build a `.yardoc` index that other tools can generate output from.
      yard_args = %w[--no-stats -n] + MODULE_SOURCEFILES
      merge_puppet_args!(yard_args)

      module_list.each do |m|
        Dir.chdir(m.path) do
          YARD::CLI::Yardoc.run(*yard_args)

          # Cear the global Registry so that objects from one module don't
          # bleed into the next.
          YARD::Registry.clear
        end
      end
    end
  end

  action(:server) do
    summary "Serve YARD documentation for modules."

    when_invoked do |*args|
      check_required_features
      require 'puppetx/yardoc/yard/plugin'
      opts = args.pop

      # FIXME: This is pretty inefficient as it forcibly re-generates the YARD
      # indicies each time the server is started. However, it ensures things are
      # generated properly.
      module_list = Puppet::Face[:yardoc, :current].modules

      module_tuples = module_list.map do |mod|
        name = (mod.forge_name || mod.name).gsub('/', '-')
        yard_index = File.join(mod.path, '.yardoc')

        [name, yard_index]
      end

      # The `-m` flag means a list of name/path pairs will follow. The name is
      # used as the module name and the path indicates which `.yardoc` index to
      # generate documentation from.
      yard_args = %w[-m] + module_tuples.flatten
      merge_puppet_args!(yard_args)

      YARD::CLI::Server.run(*yard_args)
    end
  end
end
