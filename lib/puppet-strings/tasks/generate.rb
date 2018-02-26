require 'puppet-strings'

# Implements the strings:generate task.
namespace :strings do
  desc 'Generate Puppet documentation with YARD.'
  task :generate, :patterns, :debug, :backtrace, :markup, :json, :markdown, :yard_args do |t, args|
    patterns = args[:patterns]
    patterns = patterns.split if patterns
    patterns ||= PuppetStrings::DEFAULT_SEARCH_PATTERNS

    options = {
      debug: args[:debug] == 'true',
      backtrace: args[:backtrace] == 'true',
      markup: args[:markup] || 'markdown',
    }

	# rubocop:disable Style/PreferredHashMethods
	# `args` is a Rake::TaskArguments and has no key? method
    options[:json] = args[:json] if args.has_key? :json
    options[:markdown] = args[:markdown] if args.has_key? :markdown
    options[:yard_args] = args[:yard_args].split if args.has_key? :yard_args
	# rubocop:enable Style/PreferredHashMethods

    PuppetStrings.generate(patterns, options)
  end
end

