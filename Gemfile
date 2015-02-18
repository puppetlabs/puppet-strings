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
  gem "rspec", "~> 2.14.1", :require => false
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
