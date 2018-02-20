require 'puppet-strings/markdown/base'

module PuppetStrings::Markdown
  class DefinedType < Base
    def initialize(registry)
      @template = 'classes_and_defines.erb'
      super(registry, 'defined type')
    end

    def render
      super(@template)
    end
  end
end
