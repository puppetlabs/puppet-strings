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
end

group :acceptance do
  gem 'beaker', '< 3.0'
  gem 'beaker-rspec'
  gem 'beaker-hostgenerator'
  gem 'beaker-abs'
end

group :development do
  gem 'github_changelog_generator', git: 'https://github.com/skywinder/github-changelog-generator', ref: '20ee04ba1234e9e83eb2ffb5056e23d641c7a018' if Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new('2.2.2')
  gem 'pry'
  gem 'pry-byebug'
end

gem 'rubocop', '~> 0.49'

# Evaluate Gemfile.local if it exists
if File.exists? "#{__FILE__}.local"
  eval(File.read("#{__FILE__}.local"), binding)
end

# Evaluate ~/.gemfile if it exists
if File.exists?(File.join(Dir.home, '.gemfile'))
  eval(File.read(File.join(Dir.home, '.gemfile')), binding)
end
