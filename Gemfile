source 'https://rubygems.org'

gem 'yard'
gem 'rgen'
gem 'redcarpet'
gem 'puppet-strings', '0.1.0', :path => '.'

puppetversion = ENV['PUPPET_VERSION']

if puppetversion
  gem 'puppet', puppetversion
else
  gem 'puppet', '~> 3.6.2'
end

group :test do
  gem 'rspec'
  gem 'mocha'
  gem 'puppetlabs_spec_helper'
  gem 'rspec-html-matchers'
  gem 'serverspec'
  gem 'beaker'
  gem 'beaker-rspec'
  gem 'rubocop'
end

group :development do
  gem 'pry'
  gem 'pry-debugger'
end
