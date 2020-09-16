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
  gem 'mdl', '~> 0.8.0' if Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new('2.4.0')
end

group :acceptance do
  # Litmus has dependencies which require Ruby 2.5 (Puppet 6) or above.
  if Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new('2.5.0')
    gem 'puppet_litmus', '~> 0.18'
    gem 'net-ssh', '~> 5.2'
  end
end

group :development do
  gem 'github_changelog_generator', '~> 1.15' if Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new('2.3.0')
  gem 'pry'
  gem 'pry-byebug'
end

gem 'rubocop', '~> 0.81.0' # last release that supports Ruby 2.3.0
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
