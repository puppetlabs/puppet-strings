# frozen_string_literal: true

require 'openvox-strings'

# Implements the strings:generate task.
namespace :strings do
  desc 'Generate Puppet documentation with YARD.'
  task :generate, [:patterns, :debug, :backtrace, :markup, :json, :markdown, :yard_args] do |_t, args|
    patterns = args[:patterns]
    patterns = patterns.split if patterns
    patterns ||= OpenvoxStrings::DEFAULT_SEARCH_PATTERNS

    options = {
      debug: args[:debug] == 'true',
      backtrace: args[:backtrace] == 'true',
      markup: args[:markup] || 'markdown',
    }

    raise('Error: Both JSON and Markdown output have been selected. Please select one.') if args[:json] == 'true' && args[:markdown] == 'true'

    # rubocop:disable Style/PreferredHashMethods
    # Because of Ruby, true and false from the args are both strings and both true. Here,
    # when the arg is set to false (or empty), set it to real false, else real true. Then,
    # if the arg is set simply to 'true', assume default behavior is expected and set the path
    # to nil to elicit that, else set to the path given.
    # @param [Hash] args from the Rake task cli
    # @param [Hash] options to send to the generate function
    # @param [Symbol] possible format option
    # @return nil
    def parse_format_option(args, options, format)
      return unless args.has_key? format

      options[format] = !(args[format] == 'false' || args[format].empty?)
      return unless options[format]

      options[:path] = (args[format] == 'true') ? nil : args[format]
    end
    # rubocop:enable Style/PreferredHashMethods

    %i[json markdown].each { |format| parse_format_option(args, options, format) }

    warn('yard_args behavior is a little dodgy, use at your own risk') if args[:yard_args]
    options[:yard_args] = args[:yard_args].split if args.key? :yard_args

    OpenvoxStrings.generate(patterns, options)
  end

  namespace :generate do
    desc 'Generate Puppet Reference documentation.'
    task :reference, [:patterns, :debug, :backtrace] do |_t, args|
      Rake::Task['strings:generate'].invoke(args[:patterns], args[:debug], args[:backtrace], nil, 'false', 'true')
    end
  end
end
