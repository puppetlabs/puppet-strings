require_relative 'defined_type'

module PuppetStrings::Markdown
  module DefinedTypes

    # @return [Array] list of defined types
    def self.in_dtypes
      arr = YARD::Registry.all(:puppet_defined_type).sort_by!(&:name).map!(&:to_hash)
      arr.map! { |a| PuppetStrings::Markdown::DefinedType.new(a) }
    end

    def self.contains_private?
      result = false
      unless in_dtypes.nil?
        in_dtypes.find { |type| type.private? }.nil? ? false : true
      end
    end

    def self.render
      final = in_dtypes.length > 0 ? "## Defined types\n\n" : ""
      in_dtypes.each do |type|
        final << type.render unless type.private?
      end
      final
    end

    def self.toc_info
      final = ["Defined types"]

      in_dtypes.each do |type|
        final.push(type.toc_info)
      end

      final
    end
  end
end
