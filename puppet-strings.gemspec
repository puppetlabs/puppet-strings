Gem::Specification.new do |s|
  s.name = 'puppet-strings'
  s.author = 'Puppet Labs'
  s.version = '0.4.0'
  s.license = 'Apache-2.0'
  s.summary = 'Puppet documentation via YARD'
  s.email = 'info@puppetlabs.com'
  s.homepage = 'https://github.com/puppetlabs/puppetlabs-strings'
  s.description = s.summary
  s.files = Dir['lib/**/*'].reject { |f| f if File.directory?(f) }

  s.add_runtime_dependency 'puppet', '>= 3.7.0'
  s.add_runtime_dependency 'yard', '~> 0.8'
end
