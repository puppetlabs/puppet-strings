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
