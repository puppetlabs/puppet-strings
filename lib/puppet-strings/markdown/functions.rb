require_relative 'function'

module PuppetStrings::Markdown
  module Functions

    # @return [Array] list of functions
    def self.in_functions
      arr = YARD::Registry.all(:puppet_function).sort_by!(&:name).map!(&:to_hash)
      arr.map! { |a| PuppetStrings::Markdown::Function.new(a) }
    end

    def self.contains_private?
      result = false
      unless in_functions.nil?
        in_functions.find { |func| func.private? }.nil? ? false : true
      end
    end

    def self.render
      final = in_functions.length > 0 ? "## Functions\n\n" : ""
      in_functions.each do |func|
        final << func.render unless func.private?
      end
      final
    end

    def self.toc_info
      final = ["Functions"]

      in_functions.each do |func|
        final.push(func.toc_info)
      end

      final
    end
  end
end

