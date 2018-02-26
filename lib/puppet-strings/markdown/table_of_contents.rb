module PuppetStrings::Markdown
  module TableOfContents
    def self.render
      final = ""

      [PuppetStrings::Markdown::PuppetClasses,
      PuppetStrings::Markdown::DefinedTypes,
      PuppetStrings::Markdown::ResourceTypes,
      PuppetStrings::Markdown::Functions].each do |r|
        toc = r.toc_info
        group_name = toc.shift
        group = toc
        priv = r.contains_private?

        template = File.join(File.dirname(__FILE__),"templates/table_of_contents.erb")
        final << ERB.new(File.read(template), nil, '-').result(binding)
      end
      final
    end
  end
end
