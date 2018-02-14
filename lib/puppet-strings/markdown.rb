require 'puppet-strings/json'

# module for parsing Yard Registries and generating markdown
module PuppetStrings::Markdown
  require_relative 'markdown/puppet_classes'
  require_relative 'markdown/functions'
  require_relative 'markdown/defined_types'
  require_relative 'markdown/resource_types'
  require_relative 'markdown/table_of_contents'

  # generates markdown documentation
  # @return [String] markdown doc
  def self.generate
    final = "# Reference\n\n"
    final << PuppetStrings::Markdown::TableOfContents.render
    final << PuppetStrings::Markdown::PuppetClasses.render
    final << PuppetStrings::Markdown::DefinedTypes.render
    final << PuppetStrings::Markdown::ResourceTypes.render
    final << PuppetStrings::Markdown::Functions.render

    final
  end

  def self.render(path = nil)
    if path.nil?
      puts generate
      exit
    else
      File.open(path, 'w') { |file| file.write(generate) }
    end
  end
end