# frozen_string_literal: true

# The root module for Puppet Strings.
module OpenvoxStrings
  # The glob patterns used to search for files to document.
  DEFAULT_SEARCH_PATTERNS = ['manifests/**/*.pp', 'functions/**/*.pp', 'types/**/*.pp', 'lib/**/*.rb', 'tasks/*.json', 'plans/**/*.pp'].freeze

  # Generates documentation.
  # @param [Array<String>] search_patterns The search patterns (e.g. manifests/**/*.pp) to look for files.
  # @param [Hash] options The options hash.
  # @option options [Boolean] :debug Enable YARD debug output.
  # @option options [Boolean] :backtrace Enable YARD backtraces.
  # @option options [String] :markup The YARD markup format to use (defaults to 'markdown').
  # @option options [String] :path Write the selected format to a file path
  # @option options [Boolean] :markdown From the --format option, is the format Markdown?
  # @option options [Boolean] :json Is the format JSON?
  # @option options [Array<String>] :yard_args The arguments to pass to yard.
  # @return [void]
  def self.generate(search_patterns = DEFAULT_SEARCH_PATTERNS, options = {})
    require 'openvox-strings/yard'
    OpenvoxStrings::Yard.setup!

    # Format the arguments to YARD
    args = ['doc']
    args << '--no-progress'
    args << '--debug'     if options[:debug]
    args << '--backtrace' if options[:debug]
    args << "-m#{options[:markup] || 'markdown'}"

    file = nil
    if options[:json] || options[:markdown]
      file = if options[:json]
               options[:path]
             elsif options[:markdown]
               options[:path] || 'REFERENCE.md'
             end
      # Disable output and prevent stats/progress when writing to STDOUT
      args << '-n'
      args << '-q' unless file
      args << '--no-stats' unless file
    end

    yard_args = options[:yard_args]
    args += yard_args if yard_args
    args += search_patterns

    # Run YARD
    YARD::CLI::Yardoc.run(*args)

    # If outputting JSON, render the output
    render_json(file) if options[:json] && !options[:describe]

    # If outputting Markdown, render the output
    render_markdown(file) if options[:markdown]

    return unless options[:describe]

    render_describe(options[:describe_types], options[:describe_list], options[:providers], options[:list_providers])
  end

  def self.puppet_5?
    Puppet::Util::Package.versioncmp(Puppet.version, '5.0.0') >= 0
  end

  def self.render_json(path)
    require 'openvox-strings/json'
    OpenvoxStrings::Json.render(path)
  end

  def self.render_markdown(path)
    require 'openvox-strings/markdown'
    OpenvoxStrings::Markdown.render(path)
  end

  def self.render_describe(describe_types, list = false, show_providers = true, list_providers = false)
    require 'openvox-strings/describe'
    OpenvoxStrings::Describe.render(describe_types, list, show_providers, list_providers)
  end

  # Runs the YARD documentation server.
  # @param [Array<String>] args The arguments to YARD.
  def self.run_server(*)
    require 'openvox-strings/yard'
    OpenvoxStrings::Yard.setup!

    YARD::CLI::Server.run(*)
  end
end
