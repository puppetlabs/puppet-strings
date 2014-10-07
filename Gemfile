source 'https://rubygems.org'

gem 'yard'
gem 'rgen'
gem 'redcarpet'
gem 'puppet-strings', '0.1.0', :path => '.'

if puppetversion = ENV['PUPPET_VERSION']
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
end

group :development do
  gem 'pry'
  gem 'pry-debugger'
  gem 'rubocop'
end
