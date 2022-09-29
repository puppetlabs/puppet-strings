# frozen_string_literal: true

require_relative 'puppet_class'

module PuppetStrings::Markdown
  # Generates Markdown for Puppet Classes.
  module PuppetClasses
    # @return [Array] list of classes
    def self.in_classes
      arr = YARD::Registry.all(:puppet_class).sort_by!(&:name).map!(&:to_hash)
      arr.map! { |a| PuppetStrings::Markdown::PuppetClass.new(a) }
    end

    def self.contains_private?
      return if in_classes.nil?
      in_classes.find { |klass| klass.private? }.nil? ? false : true
    end

    def self.render
      final = !in_classes.empty? ? "## Classes\n\n" : ''
      in_classes.each do |klass|
        final += klass.render unless klass.private?
      end
      final
    end

    def self.toc_info
      final = ['Classes']

      in_classes.each do |klass|
        final.push(klass.toc_info)
      end

      final
    end
  end
end
