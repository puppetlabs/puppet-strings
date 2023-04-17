# frozen_string_literal: true

require 'puppet-strings/markdown/base'

module PuppetStrings::Markdown
  # Generates Markdown for a Puppet Resource Type.
  class ResourceType < Base
    group_name 'Resource types'
    yard_types [:puppet_type]

    def initialize(registry)
      @template = 'resource_type.erb'
      super(registry, 'type')
    end

    def render
      super(@template)
    end

    def properties
      return nil unless @registry[:properties]

      @registry[:properties].sort_by { |p| p[:name] }
    end

    def checks
      return nil unless @registry[:checks]

      @registry[:checks].sort_by { |p| p[:name] }
    end

    # "checks" (such as "onlyif" or "creates") are another type of property
    def properties_and_checks
      return nil if properties.nil? && checks.nil?

      ((properties || []) + (checks || [])).sort_by { |p| p[:name] }.map do |prop|
        prop[:link] = clean_link("$#{name}::#{prop[:name]}")
        prop
      end
    end

    def parameters
      return nil unless @registry[:parameters]

      @registry[:parameters].sort_by { |p| p[:name] }.map do |param|
        param[:link] = clean_link("$#{name}::#{param[:name]}")
        param
      end
    end

    def regex_in_data_type?(data_type)
      m = data_type.match(%r{\w+\[/.*/\]})
      m unless m.nil? || m.to_a.empty?
    end
  end
end
