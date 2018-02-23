# The root module for Puppet Strings.
module PuppetStrings
  # The glob patterns used to search for files to document.
  DEFAULT_SEARCH_PATTERNS = %w(
    manifests/**/*.pp
    functions/**/*.pp
    types/**/*.pp
    lib/**/*.rb
    tasks/*.json
  ).freeze

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
    require 'puppet-strings/yard'
    PuppetStrings::Yard.setup!

    # Format the arguments to YARD
    args = ['doc']
    args << '--debug'     if options[:debug]
    args << '--backtrace' if options[:backtrace]
    args << "-m#{options[:markup] || 'markdown'}"

    file = nil
    if options[:json] || options[:markdown]
      file = if options[:json]
               options[:path]
             elsif options[:markdown]
               options[:path] || "REFERENCE.md"
             end
      # Disable output and prevent stats/progress when writing to STDOUT
      args << '-n'
      args << '-q' unless file
      args << '--no-stats' unless file
      args << '--no-progress' unless file
    end

    yard_args = options[:yard_args]
    args += yard_args if yard_args
    args += search_patterns

    # Run YARD
    YARD::CLI::Yardoc.run(*args)

    # If outputting JSON, render the output
    if options[:json]
      render_json(file)
    end

    # If outputting Markdown, render the output
    if options[:markdown]
      render_markdown(file)
    end
  end

  def self.render_json(path)
    require 'puppet-strings/json'
    PuppetStrings::Json.render(path)
  end

  def self.render_markdown(path)
    require 'puppet-strings/markdown'
    PuppetStrings::Markdown.render(path)
  end

  # Runs the YARD documentation server.
  # @param [Array<String>] args The arguments to YARD.
  def self.run_server(*args)
    require 'puppet-strings/yard'
    PuppetStrings::Yard.setup!

    YARD::CLI::Server.run(*args)
  end
end
