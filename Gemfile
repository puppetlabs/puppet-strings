# frozen_string_literal: true

source ENV['GEM_SOURCE'] || 'https://rubygems.org'

gemspec

def location_for(place_or_version, fake_version = nil)
  git_url_regex = /\A(?<url>(https?|git)[:@][^#]*)(#(?<branch>.*))?/
  file_url_regex = %r{\Afile://(?<path>.*)}

  if place_or_version && (git_url = place_or_version.match(git_url_regex))
    [fake_version, { git: git_url[:url], branch: git_url[:branch], require: false }].compact
  elsif place_or_version && (file_url = place_or_version.match(file_url_regex))
    ['>= 0', { path: File.expand_path(file_url[:path]), require: false }]
  else
    [place_or_version, { require: false }]
  end
end

group :development do
  gem 'json_spec', '~> 1.1', '>= 1.1.5'

  gem 'mdl', '~> 0.11.0'

  gem 'mocha', '~> 2.7'

  gem 'rake'
  gem 'rspec', '~> 3.1'
  gem 'rspec-its', '~> 1.0'

  gem 'redcarpet'
end

# https://github.com/OpenVoxProject/puppet/issues/90
gem 'syslog', '~> 0.3' if RUBY_VERSION >= '3.4'

group :release, optional: true do
  gem 'faraday-retry', '~> 2.1', require: false
  gem 'github_changelog_generator', '~> 1.16.4', require: false
end
