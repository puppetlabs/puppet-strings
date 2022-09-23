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

group :test do
  gem 'codecov'
  gem 'mocha'
  gem 'puppetlabs_spec_helper'
  gem 'serverspec'
  gem 'simplecov-console'
  gem 'rspec', '~> 3.1'
  gem 'json_spec', '~> 1.1', '>= 1.1.5'
  gem 'mdl'
end

group :acceptance do
  gem 'puppet_litmus'
  gem 'net-ssh'
end

group :development do
  gem 'github_changelog_generator'
  gem 'pry'
  gem 'pry-byebug'
end

gem 'rubocop', '~> 0.81.0' # Requires work to upgrade
gem 'rubocop-rspec'
gem 'rubocop-performance'

# Evaluate Gemfile.local if it exists
if File.exists? "#{__FILE__}.local"
  eval(File.read("#{__FILE__}.local"), binding)
end

# Evaluate ~/.gemfile if it exists
if File.exists?(File.join(Dir.home, '.gemfile'))
  eval(File.read(File.join(Dir.home, '.gemfile')), binding)
end
