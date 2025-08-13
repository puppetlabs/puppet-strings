# frozen_string_literal: true

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.exclude_pattern = 'spec/acceptance/**/*.rb'
end

RSpec::Core::RakeTask.new(:acceptance) do |t|
  t.pattern = 'spec/unit/**/*.rb'
end

desc 'run unit tests'
task :spec

desc 'run acceptance tests'
task :acceptance

# Add our own tasks
require 'openvox-strings/tasks'

begin
  require 'voxpupuli/rubocop/rake'
rescue LoadError
  # the voxpupuli-rubocop gem is optional
end

desc 'Validate Ruby source files and ERB templates.'
task :validate do
  Dir['spec/**/*.rb', 'lib/**/*.rb'].each do |ruby_file|
    sh "ruby -c #{ruby_file}" unless ruby_file.include?('spec/fixtures')
  end
  Dir['lib/puppet-strings/yard/templates/**/*.erb'].each do |template|
    sh "erb -P -x -T '-' #{template} | ruby -c"
  end
end

task default: %i[validate spec]

begin
  require 'github_changelog_generator/task'
  require 'openvox-strings/version'
  GitHubChangelogGenerator::RakeTask.new :changelog do |config|
    version = OpenvoxStrings::VERSION
    config.future_release = "v#{version}" if /^\d+\.\d+.\d+$/.match?(version)
    config.header = "# Changelog\n\nAll notable changes to this project will be documented in this file."
    config.exclude_labels = %w[duplicate question invalid wontfix wont-fix modulesync skip-changelog github_actions]
    config.user = 'voxpupuli'
    config.project = 'openvox-strings'
    config.since_tag = 'v4.1.3'
  end
rescue LoadError
  # GCG is an optional gem
end
