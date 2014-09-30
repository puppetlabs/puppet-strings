require 'puppetx/puppetlabs/strings'

class Puppetx::PuppetLabs::Strings::Actions

  # Creates a new instance of the Actions class by determining
  # whether or not debug and backtrace arguments should be sent
  # to YARD
  def initialize(puppet_debug, puppet_backtrace)
    @debug = puppet_debug
    @backtrace = puppet_backtrace
  end

  # Holds the name of a module and the file path to its YARD index
  ModuleIndex = Struct.new(:name, :index_path)


  # Maps things like the Puppet `--debug` flag to YARD options.
  def merge_puppet_args!(yard_args)
    yard_args.unshift '--debug'     if @debug
    yard_args.unshift '--backtrace' if @backtrace

    yard_args
  end

  # Builds doc indices (.yardoc directories) for modules.
  # Currently lacks the fine-grained control over where these
  # indices are created and just dumps them in the module roots.
  #
  # @return [Array<Module>] the modules to be documented
  #
  # @param [Array<String>] module_names a list of the module source files
  # @param [Array<String>] module_sourcefiles default list of module files
  def index_documentation_for_modules(module_names, module_sourcefiles)
    # NOTE: The return value of the `module` Face seems to have changed in
    # 3.6.x. This part of the code will blow up if run under an earlier
    # version of Puppet.
    modules = Puppet::Face[:module, :current].list
    module_list = modules[:modules_by_path].values.flatten

    module_list.select! {|m| module_names.include? m.name} unless module_names.empty?

    # Invoke `yardoc` with -n so that it doesn't generate any HTML output but
    # does build a `.yardoc` index that other tools can generate output from.
    yard_args = %w[--no-stats -n] + module_sourcefiles
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
  # @param [Array<String>] module_list a list of the module source files
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
  # @param [Array<String>] yard_args a list of all the arguments to pass to YARD
  def serve_documentation(*yard_args)
    merge_puppet_args!(yard_args)
    YARD::CLI::Server.run(*yard_args)
  end

  # Hands off the needed information to YARD so it may
  # generate the documentation
  #
  # @param [Array<String>] yard_args a list of all the arguments to pass to YARD
  def generate_documentation(*yard_args)
    merge_puppet_args!(yard_args)
    YARD::CLI::Yardoc.run(*yard_args)
  end
end

