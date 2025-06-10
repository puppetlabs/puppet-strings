# frozen_string_literal: true

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.exclude_pattern = "spec/acceptance/**/*.rb"
end

RSpec::Core::RakeTask.new(:acceptance) do |t|
  t.pattern = "spec/unit/**/*.rb"
end

task :spec
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
