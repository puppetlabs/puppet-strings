require 'puppet/face'

# Implements the 'puppet strings' interface.
Puppet::Face.define(:strings, '0.0.1') do
  summary 'Generate Puppet documentation with YARD.'

  action(:generate) do
    default

    option '--emit-json-stdout' do
      summary 'Print JSON representation of the documentation to stdout.'
    end
    option '--emit-json FILE' do
      summary 'Write JSON representation of the documentation to the given file.'
    end
    option '--markup FORMAT' do
      summary "The markup format to use for docstring text (defaults to 'markdown')."
    end

    summary 'Generate documentation from files.'
    arguments '[[search_pattern] ...]'

    when_invoked do |*args|
      check_required_features
      require 'puppet-strings'

      PuppetStrings::generate(
        args.count > 1 ? args[0..-2] : PuppetStrings::DEFAULT_SEARCH_PATTERNS,
        build_generate_options(args.last)
      )
      nil
    end
  end

  action(:server) do
    option '--markup FORMAT' do
      summary "The markup format to use for docstring text (defaults to 'markdown')."
    end

    summary 'Runs a local documentation server for the modules in the current Puppet environment.'
    arguments '[[module_name] ...]'

    when_invoked do |*args|
      check_required_features
      require 'puppet-strings'

      modules = args.count > 1 ? args[0..-2] : []

      # Generate documentation for all (or the given) modules
      module_docs = []
      environment = Puppet.lookup(:current_environment)
      environment.modules.each do |mod|
        next unless modules.empty? || modules.include?(mod.name)
        db = File.join(mod.path, '.yardoc')
        patterns = PuppetStrings::DEFAULT_SEARCH_PATTERNS.map do |p|
          File.join(mod.path, p)
        end
        puts "Generating documentation for Puppet module '#{mod.name}'."
        PuppetStrings.generate(patterns, build_generate_options(args.last, '--db', db))

        # Clear the registry so that the next call to generate has a clean database
        YARD::Registry.clear

        module_docs << mod.name
        module_docs << db
      end

      if module_docs.empty?
        puts 'No Puppet modules were found to serve documentation for.'
        return
      end
      puts 'Starting YARD documentation server.'
      PuppetStrings::run_server('-m', *module_docs)
      nil
    end
  end

  # Checks that the required features are installed.
  # @return [void]
  def check_required_features
    raise RuntimeError, "The 'yard' gem must be installed in order to use this face." unless Puppet.features.yard?
    raise RuntimeError, "The 'rgen' gem must be installed in order to use this face." unless Puppet.features.rgen?
    raise RuntimeError, 'This face requires Ruby 1.9 or greater.' if RUBY_VERSION =~ /^1\.8/
  end

  # Builds the options to PuppetStrings.generate.
  # @param [Hash] options The Puppet face options hash.
  # @param [Array] yard_args The additional arguments to pass to YARD.
  # @return [Hash] Returns the PuppetStrings.generate options hash.
  def build_generate_options(options = nil, *yard_args)
    generate_options = {}
    generate_options[:debug] = Puppet[:debug]
    generate_options[:backtrace] = Puppet[:trace]
    generate_options[:yard_args] = yard_args unless yard_args.empty?

    if options
      markup = options[:markup]
      generate_options[:markup] = markup if markup
      json_file = options[:emit_json]
      generate_options[:json] = json_file if json_file
      generate_options[:json] = nil if options[:emit_json_stdout]
    end
    generate_options
  end

  action(:authors) do
    summary "Shows a list of authors from @author tags in a given list of Puppet manifests"
    arguments "[module-name ...]"

    when_invoked do |*args|
      check_required_features
      require 'puppetx/puppetlabs/strings/yard/plugin'
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
      yard_args = %w[--no-stats -n -q] + MODULE_SOURCEFILES
      merge_puppet_args!(yard_args)

      module_list.each do |m|
        Dir.chdir(m.path) do
          YARD::CLI::Yardoc.run(*yard_args)

          YARD::Registry.all(:hostclass, :definedtype).map do | e |
            authors = e.tags.select {|t| t.tag_name = 'author'}.map{|t| t.text }
            puts authors
          end

          # Cear the global Registry so that objects from one module don't
          # bleed into the next.
          YARD::Registry.clear
        end
      end
    end
  end
end