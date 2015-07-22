source 'https://rubygems.org'

gemspec

gem 'yard'
gem 'rgen'
gem 'redcarpet'

puppetversion = ENV['PUPPET_VERSION']

if puppetversion
  gem 'puppet', puppetversion
else
  gem 'puppet'
end

group :test do
  gem "rspec"
  gem 'mocha'
  gem 'puppetlabs_spec_helper'
  gem 'serverspec'
  gem 'beaker'
  gem 'beaker-rspec'
  gem 'rubocop'
end

group :development do
  gem 'pry'
  if RUBY_VERSION[0..2] == '1.9'
    gem 'pry-debugger'
  elsif RUBY_VERSION[0] == '2'
    gem 'pry-byebug'
  end
end
