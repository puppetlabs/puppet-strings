require 'puppet-strings/markdown/base'

module PuppetStrings::Markdown
  class PuppetClass < Base
    def initialize(registry)
      @template = 'puppet_resource.erb'
      super(registry, 'class')
    end

    def render
      super(@template)
    end
  end
end
