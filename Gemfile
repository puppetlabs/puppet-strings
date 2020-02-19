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
end

group :acceptance do
  # Litmus has dependencies which require Ruby 2.5 (Puppet 6) or above.
  if Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new('2.5.0')
    # Until https://github.com/puppetlabs/puppet_litmus/pull/248 is merged we need to use the source of the
    # of the PR.  Not the greatest and prone to error, but without it, all litmus based testing is broken.
    # This can be reverted once this PR is merged and Litmus is released with this fix.
    gem 'puppet_litmus', git: 'https://github.com/michaeltlombardi/puppet_litmus', ref: 'maint/master/fix-upload-file'
    gem 'net-ssh', '~> 5.2'
  end
end

group :development do
  gem 'github_changelog_generator', git: 'https://github.com/skywinder/github-changelog-generator', ref: '20ee04ba1234e9e83eb2ffb5056e23d641c7a018' if Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new('2.2.2')
  gem 'pry'
  gem 'pry-byebug'
end

gem 'rubocop-rspec'
gem 'rubocop', '~> 0.57.2'

# Evaluate Gemfile.local if it exists
if File.exists? "#{__FILE__}.local"
  eval(File.read("#{__FILE__}.local"), binding)
end

# Evaluate ~/.gemfile if it exists
if File.exists?(File.join(Dir.home, '.gemfile'))
  eval(File.read(File.join(Dir.home, '.gemfile')), binding)
end
