# frozen_string_literal: true

require_relative 'resource_type'

module PuppetStrings::Markdown
  # Generates Markdown for Puppet Resource Types.
  module ResourceTypes
    # @return [Array] list of resource types
    def self.in_rtypes
      arr = YARD::Registry.all(:puppet_type).sort_by!(&:name).map!(&:to_hash)
      arr.map! { |a| PuppetStrings::Markdown::ResourceType.new(a) }
    end

    def self.contains_private?
      return if in_rtypes.nil?
      in_rtypes.find { |type| type.private? }.nil? ? false : true
    end

    def self.render
      final = !in_rtypes.empty? ? "## Resource types\n\n" : ''
      in_rtypes.each do |type|
        final += type.render unless type.private?
      end
      final
    end

    def self.toc_info
      final = ['Resource types']

      in_rtypes.each do |type|
        final.push(type.toc_info)
      end

      final
    end
  end
end
