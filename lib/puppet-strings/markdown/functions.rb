require_relative 'function'

module PuppetStrings::Markdown
  module Functions

    # @return [Array] list of functions
    def self.in_functions
      YARD::Registry.all(:puppet_function).sort_by!(&:name).map!(&:to_hash)
    end

    def self.render
      final = in_functions.length > 0 ? "## Functions\n\n" : ""
      in_functions.each do |func|
        to_render = PuppetStrings::Markdown::Function.new(func)
        final << to_render.render if to_render.contains_displayed_tags?
      end
      final
    end

    def self.toc_info
      final = []

      in_functions.each do |func|
        final.push(PuppetStrings::Markdown::Function.new(func).toc_info)
      end

      final
    end
  end
end

