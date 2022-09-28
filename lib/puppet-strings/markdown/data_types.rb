# frozen_string_literal: true

require_relative 'data_type'

module PuppetStrings::Markdown
  # Generates Markdown for Puppet Data Types.
  module DataTypes
    # @return [Array] list of data types
    def self.in_dtypes
      arr = YARD::Registry.all(:puppet_data_type).map!(&:to_hash)
      arr.concat(YARD::Registry.all(:puppet_data_type_alias).map!(&:to_hash))

      arr.sort! { |a, b| a[:name] <=> b[:name] }
      arr.map! { |a| PuppetStrings::Markdown::DataType.new(a) }
    end

    def self.contains_private?
      return if in_dtypes.nil?
      in_dtypes.find { |type| type.private? }.nil? ? false : true
    end

    def self.render
      final = !in_dtypes.empty? ? "## Data types\n\n" : ''
      in_dtypes.each do |type|
        final += type.render unless type.private?
      end
      final
    end

    def self.toc_info
      final = ['Data types']

      in_dtypes.each do |type|
        final.push(type.toc_info)
      end

      final
    end
  end
end
