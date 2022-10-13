# frozen_string_literal: true

source ENV['GEM_SOURCE'] || "https://rubygems.org"

gemspec

gem 'rgen'
gem 'redcarpet'
gem 'yard', '~> 0.9.11'

if ENV['PUPPET_GEM_VERSION']
  gem 'puppet', ENV['PUPPET_GEM_VERSION'], :require => false
else
  gem 'puppet', :require => false
end

group :development do
  gem 'codecov'

  gem 'json_spec', '~> 1.1', '>= 1.1.5'

  gem 'mdl'
  gem 'mocha'

  gem 'pry', require: false
  gem 'pry-byebug', require: false
  gem 'pry-stack_explorer', require: false
  gem 'puppetlabs_spec_helper'

  gem 'rake'
  gem 'rspec', '~> 3.1'
  gem 'rspec-its', '~> 1.0'
  gem 'rubocop', '~> 1.6.1', require: false
  gem 'rubocop-rspec', '~> 2.0.1', require: false
  gem 'rubocop-performance', '~> 1.9.1', require: false

  gem 'serverspec'
  gem 'simplecov-console', require: false if ENV['COVERAGE'] == 'yes'
  gem 'simplecov', require: false if ENV['COVERAGE'] == 'yes'
end

group :acceptance do
  gem 'puppet_litmus'
  gem 'net-ssh'
end

group :release do
  gem 'github_changelog_generator', require: false
end

# Evaluate Gemfile.local if it exists
if File.exists? "#{__FILE__}.local"
  eval(File.read("#{__FILE__}.local"), binding)
end

# Evaluate ~/.gemfile if it exists
if File.exists?(File.join(Dir.home, '.gemfile'))
  eval(File.read(File.join(Dir.home, '.gemfile')), binding)
end
