require_relative 'resource_type'

module PuppetStrings::Markdown
  module ResourceTypes

    # @return [Array] list of resource types
    def self.in_rtypes
      YARD::Registry.all(:puppet_type).sort_by!(&:name).map!(&:to_hash)
    end

    def self.render
      final = in_rtypes.length > 0 ? "## Resource types\n\n" : ""
      in_rtypes.each do |type|
        to_render = PuppetStrings::Markdown::ResourceType.new(type)
        final << to_render.render if to_render.contains_displayed_tags?
      end
      final
    end

    def self.toc_info
      final = []

      in_rtypes.each do |type|
        final.push(PuppetStrings::Markdown::ResourceType.new(type).toc_info)
      end

      final
    end
  end
end
