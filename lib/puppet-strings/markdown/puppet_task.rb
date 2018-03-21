require 'puppet-strings/markdown/base'

module PuppetStrings::Markdown
  class PuppetTask < Base
    def initialize(registry)
      @template = 'puppet_task.erb'
      @registry = registry
      super(registry, 'task')
    end

    def render
      super(@template)
    end

    def supports_noop
      @registry[:supports_noop]
    end

    def input_method
      @registry[:input_method]
    end

  end
end
