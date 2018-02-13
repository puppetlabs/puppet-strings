require 'puppet-strings/markdown/base'

module PuppetStrings::Markdown
  class PuppetClass < Base
    def initialize(registry)
      @template = 'classes_and_defines.erb'
      super(registry, 'class')
    end

    def render
      super(@template)
    end
  end
end
