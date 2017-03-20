Gem::Specification.new do |s|
  s.name = 'puppet-strings'
  s.author = 'Puppet Inc.'
  s.version = '1.1.0'
  s.license = 'Apache-2.0'
  s.summary = 'Puppet documentation via YARD'
  s.email = 'info@puppet.com'
  s.homepage = 'https://github.com/puppetlabs/puppet-strings'
  s.description = s.summary
  s.required_ruby_version = '>= 1.9.3'

  s.extra_rdoc_files = [
    'CHANGELOG.md',
    'COMMITTERS.md',
    'CONTRIBUTING.md',
    'LICENSE',
    'README.md',
  ]
  s.files = `git ls-files`.split("\n") - Dir['.*', '*.gemspec']

  s.add_runtime_dependency 'yard', '~> 0.9.5'
  s.requirements << 'puppet, >= 3.7.0'
end
