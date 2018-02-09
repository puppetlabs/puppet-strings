require 'puppet-strings/markdown/base'

module PuppetStrings::Markdown
  class PuppetResourceType < Base
    def initialize(registry)
      @template = 'puppet_resource_type.erb'
      super(registry, 'resource type')
    end

    def render
      super(@template)
    end

    def properties
      @registry[:properties]
    end

    def parameters
      @registry[:parameters]
    end

    def regex_in_data_type?(data_type)
      m = data_type.match(/\w+\[\/.*\/\]/)
      m unless m.nil? || m.length.zero?
    end
  end
end
