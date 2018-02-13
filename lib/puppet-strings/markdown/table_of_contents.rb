module PuppetStrings::Markdown
  module TableOfContents
    def self.render
      puppet_classes = PuppetStrings::Markdown::PuppetClasses.toc_info
      puppet_defined_types = PuppetStrings::Markdown::DefinedTypes.toc_info
      puppet_resource_types = PuppetStrings::Markdown::CustomTypes.toc_info
      puppet_functions = PuppetStrings::Markdown::Functions.toc_info

      template = File.join(File.dirname(__FILE__),"templates/table_of_contents.erb")
      ERB.new(File.read(template), nil, '-').result(binding)
    end
  end
end
