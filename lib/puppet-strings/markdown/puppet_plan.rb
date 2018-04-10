require 'puppet-strings/markdown/base'

module PuppetStrings::Markdown
  class PuppetPlan < Base
    def initialize(registry)
      @template = 'classes_and_defines.erb'
      super(registry, 'plan')
    end

    def render
      super(@template)
    end
  end
end
