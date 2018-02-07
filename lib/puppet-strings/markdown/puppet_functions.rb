require_relative 'puppet_function'

module PuppetStrings::Markdown
  module PuppetFunctions

    # @return [Array] list of functions
    def self.in_functions
      YARD::Registry.all(:puppet_function).sort_by!(&:name).map!(&:to_hash)
    end

    def self.render
      final = in_functions.length > 0 ? "## Functions\n\n" : ""
      in_functions.each do |func|
        final << PuppetStrings::Markdown::PuppetFunction.new(func).render
      end
      final
    end

    def self.toc_info
      final = []

      in_functions.each do |func|
        final.push(PuppetStrings::Markdown::PuppetFunction.new(func).toc_info)
      end

      final
    end
  end
end

