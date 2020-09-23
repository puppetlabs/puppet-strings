# frozen_string_literal: true

require 'puppet-strings/markdown/base'

module PuppetStrings::Markdown
  class ResourceType < Base
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

      ((properties || []) + (checks || [])).sort_by { |p| p[:name] }
    end

    def parameters
      return nil unless @registry[:parameters]

      @registry[:parameters].sort_by { |p| p[:name] }
    end

    def regex_in_data_type?(data_type)
      m = data_type.match(/\w+\[\/.*\/\]/)
      m unless m.nil? || m.length.zero?
    end
  end
end
