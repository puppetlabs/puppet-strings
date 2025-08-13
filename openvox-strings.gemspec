# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'openvox-strings/version'

Gem::Specification.new do |s|
  s.name = 'openvox-strings'
  s.author = ['Puppet Inc.', 'Vox Pupuli']
  s.version = OpenvoxStrings::VERSION
  s.license = 'Apache-2.0'
  s.summary = 'Puppet documentation via YARD'
  s.email = 'voxpupuli@groups.io'
  s.homepage = 'https://github.com/voxpupuli/openvox-strings'
  s.required_ruby_version = '>= 3.2.0'

  s.extra_rdoc_files = [
    'CHANGELOG.md',
    'LICENSE',
    'README.md',
  ]
  s.files = Dir['CHANGELOG.md', 'README.md', 'LICENSE', 'lib/**/*', 'exe/**/*']

  s.add_dependency 'openvox', '>= 7', '< 9'
  s.add_dependency 'rgen', '>= 0.9', '< 0.11'
  s.add_dependency 'yard', '~> 0.9'

  s.add_development_dependency 'voxpupuli-rubocop', '~> 4.2.0'
end
