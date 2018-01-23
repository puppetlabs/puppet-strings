require 'puppet-strings/markdown/puppet_classes'

module PuppetStrings::Markdown
  module TableOfContents
    def self.render
      puppet_classes = PuppetStrings::Markdown::PuppetClasses.toc_info
      puppet_defined_types = PuppetStrings::Markdown::PuppetDefinedTypes.toc_info
      puppet_resource_types = PuppetStrings::Markdown::PuppetResourceTypes.toc_info
      puppet_functions = PuppetStrings::Markdown::PuppetFunctions.toc_info

      template = File.join(File.dirname(__FILE__),"templates/table_of_contents.erb")
      ERB.new(File.read(template), nil, '-').result(binding)
    end
  end
end
