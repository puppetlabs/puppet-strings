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
  gem "rspec", "~> 3.1"
end

group :acceptance do
  gem 'beaker', '< 3.0'
  gem 'beaker-rspec'
  gem 'beaker-hostgenerator'
  gem 'beaker-abs'
end

group :development do
  gem 'pry'
  if RUBY_VERSION[0..2] == '1.9'
    gem 'pry-debugger'
  elsif RUBY_VERSION[0] == '2'
    gem 'pry-byebug'
  end
end

gem 'json',      '<= 1.8'    if RUBY_VERSION < '2.0.0'
gem 'json_pure', '<= 2.0.1'  if RUBY_VERSION < '2.0.0'
gem 'rubocop',   '<= 0.47.0' if RUBY_VERSION >= '2.0.0'
