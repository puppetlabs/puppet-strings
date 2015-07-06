source 'https://rubygems.org'

gem 'yard'
gem 'rgen'
gem 'redcarpet'
gem 'puppet-strings', '0.1.0', :path => '.'

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
