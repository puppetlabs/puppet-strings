require 'puppetx/puppetlabs/strings'

module Puppetx::PuppetLabs::Strings::Actions

  # Holds the name of a module and the file path to its YARD index
  ModuleIndex = Struct.new(:name, :index_path)

  # A list of globs that generates the default list of module files from which
  # documentation can be extracted.
  #
  # TODO: It would be awesome if we could somehow override/append to the
  # default file list that YARD uses. Consider an upstream PR for this.
  MODULE_SOURCEFILES = ['manifests/**/*.pp', 'lib/**/*.rb']

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

  # Maps things like the Puppet `--debug` flag to YARD options.
  def merge_puppet_args!(yard_args)
    yard_args.unshift '--debug'     if Puppet[:debug]
    yard_args.unshift '--backtrace' if Puppet[:trace]

    yard_args
  end

  # Builds doc indices (.yardoc directories) for modules.
  # Currently lacks the fine-grained control over where these
  # indices are created and just dumps them in the module roots.
  #
  # @return [Array<Module>] the modules to be documented
  #
  # @param [Array<String>] a list of the module source files
  def index_documentation_for_modules(module_names)
    # NOTE: The return value of the `module` Face seems to have changed in
    # 3.6.x. This part of the code will blow up if run under an earlier
    # version of Puppet.
    modules = Puppet::Face[:module, :current].list
    module_list = modules[:modules_by_path].values.flatten

    # TODO: Can use select! if Ruby 1.8.7 support is dropped.
    module_list.select! {|m| module_names.include? m.name} unless module_names.empty?

    # Invoke `yardoc` with -n so that it doesn't generate any HTML output but
    # does build a `.yardoc` index that other tools can generate output from.
    yard_args = %w[--no-stats -n] + MODULE_SOURCEFILES
    merge_puppet_args!(yard_args)

    module_list.each do |m|
      Dir.chdir(m.path) do
        YARD::CLI::Yardoc.run(*yard_args)

        # Clear the global Registry so that objects from one module don't
        # bleed into the next.
        YARD::Registry.clear
      end
    end
  end

  # Extracts the needed information of the modules we're documenting
  #
  # @return [Array<ModuleIndex>] An array of representation of the modules
  # to produce documentation for. Each ModuleIndex contains the module name
  # and the path to its YARD index
  #
  # @param [Array<String>] a list of the module source files
  def generate_module_tuples(module_list)
    module_list.map do |mod|
      name = (mod.forge_name || mod.name).gsub('/', '-')
      yard_index = File.join(mod.path, '.yardoc')

      ModuleIndex.new(name, yard_index)
    end
  end

  # Hands off the needed information to YARD so it may
  # serve the documentation
  #
  # @param [Array<String>] a list of all the arguments to pass to YARD
  def serve_documentation(*yard_args)
    merge_puppet_args!(yard_args)
    YARD::CLI::Server.run(*yard_args)
  end

  # Hands off the needed information to YARD so it may
  # generate the documentation
  #
  # @param [Array<String>] a list of all the arguments to pass to YARD
  def generate_documentation(*yard_args)
    merge_puppet_args!(yard_args)
    YARD::CLI::Yardoc.run(*yard_args)
  end
end

