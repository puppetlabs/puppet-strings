require 'puppet-strings/markdown/base'

module PuppetStrings::Markdown
  class PuppetDefinedType < Base
    def initialize(registry)
      @template = 'puppet_resource.erb'
      super(registry, 'defined type')
    end

    def render
      super(@template)
    end
  end
end
