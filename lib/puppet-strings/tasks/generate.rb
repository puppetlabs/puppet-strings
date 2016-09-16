require 'puppet-strings'

# Implements the strings:generate task.
namespace :strings do
  desc 'Generate Puppet documentation with YARD.'
  task :generate, :patterns, :debug, :backtrace, :markup, :json, :yard_args do |t, args|
    patterns = args[:patterns]
    patterns = patterns.split if patterns
    patterns ||= PuppetStrings::DEFAULT_SEARCH_PATTERNS

    options = {
      debug: args[:debug] == 'true',
      backtrace: args[:backtrace] == 'true',
      markup: args[:markup] || 'markdown',
    }

    options[:json] = args[:json] if args.key? :json
    options[:yard_args] = args[:yard_args].split if args.key? :yard_args

    PuppetStrings.generate(patterns, options)
  end
end

