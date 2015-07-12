require 'json'

puppet_metadata = JSON.load File.open(File.expand_path(File.join(__FILE__, '..', 'metadata.json'))).read

Gem::Specification.new do |s|
    s.name = 'puppet-strings'
    s.author = puppet_metadata['author']
    s.version = puppet_metadata['version']
    s.license = puppet_metadata['license']
    s.summary = puppet_metadata['summary']
    s.homepage = puppet_metadata['project_page']

    s.description = s.summary
    s.files = Dir['lib/**/*'].reject { |f| f if File.directory?(f) }

    s.add_runtime_dependency 'puppet', '>= 3.7.0'
    s.add_runtime_dependency 'yard'
end
