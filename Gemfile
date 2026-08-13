# frozen_string_literal: true

# For puppetcore, set GEM_SOURCE_PUPPETCORE = 'https://rubygems-puppetcore.puppet.com'
gemsource_default = ENV['GEM_SOURCE'] || "https://rubygems.org"
gemsource_puppetcore = if !ENV['PUPPET_FORGE_TOKEN'].to_s.empty?
                         'https://rubygems-puppetcore.puppet.com'
                       else
                         ENV['GEM_SOURCE_PUPPETCORE'] || gemsource_default
                       end
source gemsource_default

gemspec

def location_for(place_or_version, fake_version = nil, opts = {})
  git_url_regex = %r{\A(?<url>(https?|git)[:@][^#]*)(#(?<branch>.*))?}
  file_url_regex = %r{\Afile:\/\/(?<path>.*)}

  if place_or_version && (git_url = place_or_version.match(git_url_regex))
    [fake_version, { git: git_url[:url], branch: git_url[:branch], require: false }].compact
  elsif place_or_version && (file_url = place_or_version.match(file_url_regex))
    ['>= 0', { path: File.expand_path(file_url[:path]), require: false }]
  else
    [place_or_version, { require: false }.merge(opts)]
  end
end

group :development do
  gem 'puppet', *location_for(ENV.fetch('PUPPET_GEM_VERSION', nil), nil, { source: gemsource_puppetcore })

  gem 'json_spec', '~> 1.1', '>= 1.1.5'

  gem 'mdl', '~> 0.11.0'

  gem 'pry', require: false
  gem 'pry-byebug', require: false
  gem 'pry-stack_explorer', require: false

  # Need the following otherwise we end up with puppetlabs_spec_helper 1.1.1
  gem 'mocha', '~> 1.0'
  gem 'puppetlabs_spec_helper'

  gem 'rake'
  gem 'rspec', '~> 3.1'
  gem 'rspec-its', '~> 1.0'

  gem 'rubocop', '~> 1.70.0', require: false
  gem 'rubocop-performance', '~> 1.16', require: false
  gem 'rubocop-rspec', '~> 3.0', require: false

  gem 'serverspec'
  gem 'simplecov', require: false
  gem 'simplecov-console', require: false

  gem 'redcarpet'
end

group :acceptance do
  gem 'puppet_litmus'
  gem 'net-ssh'
end
