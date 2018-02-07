require_relative 'puppet_defined_type'

module PuppetStrings::Markdown
  module PuppetDefinedTypes

    # @return [Array] list of defined types
    def self.in_dtypes
      YARD::Registry.all(:puppet_defined_type).sort_by!(&:name).map!(&:to_hash)
    end

    def self.render
      final = in_dtypes.length > 0 ? "## Defined types\n\n" : ""
      in_dtypes.each do |type|
        final << PuppetStrings::Markdown::PuppetDefinedType.new(type).render
      end
      final
    end

    def self.toc_info
      final = []

      in_dtypes.each do |type|
        final.push(PuppetStrings::Markdown::PuppetDefinedType.new(type).toc_info)
      end

      final
    end
  end
end
