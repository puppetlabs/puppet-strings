module PuppetStrings::Markdown
  module TableOfContents
    def self.render
      final = "## Table of Contents\n\n"

      [PuppetStrings::Markdown::PuppetClasses,
      PuppetStrings::Markdown::DefinedTypes,
      PuppetStrings::Markdown::ResourceTypes,
      PuppetStrings::Markdown::Functions,
      PuppetStrings::Markdown::DataTypes,
      PuppetStrings::Markdown::PuppetTasks,
      PuppetStrings::Markdown::PuppetPlans].each do |r|
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
