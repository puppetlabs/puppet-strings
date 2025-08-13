# frozen_string_literal: true

require 'openvox-strings'
require 'tempfile'

namespace :strings do
  namespace :validate do
    desc 'Validate the reference is up to date'
    task :reference, [:patterns, :debug, :backtrace] do |_t, args|
      filename = 'REFERENCE.md'

      unless File.exist?(filename)
        warn "#{filename} does not exist"
        exit 1
      end

      patterns = args[:patterns]
      patterns = patterns.split if patterns
      patterns ||= OpenvoxStrings::DEFAULT_SEARCH_PATTERNS

      generated = Tempfile.create do |file|
        options = {
          debug: args[:debug] == 'true',
          backtrace: args[:backtrace] == 'true',
          json: false,
          markdown: true,
          path: file,
        }
        OpenvoxStrings.generate(patterns, options)

        file.read
      end

      existing = File.read(filename)

      if generated != existing
        warn "#{filename} is outdated; to regenerate: bundle exec rake strings:generate:reference"
        exit 1
      end
    end
  end
end
