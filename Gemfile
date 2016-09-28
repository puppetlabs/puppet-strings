source ENV['GEM_SOURCE'] || "https://rubygems.org"

gemspec

gem 'rgen'
gem 'redcarpet'
gem 'yard', '~> 0.9.5'

puppetversion = ENV['PUPPET_VERSION']

if puppetversion
  gem 'puppet', puppetversion
else
  gem 'puppet'
end

group :test do
  gem "rspec", "~> 3.1"
  gem 'mocha'
  gem 'puppetlabs_spec_helper'
  gem 'serverspec'
  gem 'rubocop', '~> 0.41.0'
end

group :acceptance do
  gem 'beaker', '< 3.0'
  gem 'beaker-rspec'
  gem 'beaker-hostgenerator'
end

group :development do
  gem 'pry'
  if RUBY_VERSION[0..2] == '1.9'
    gem 'pry-debugger'
  elsif RUBY_VERSION[0] == '2'
    gem 'pry-byebug'
  end
end
