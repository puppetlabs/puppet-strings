require 'puppet-strings/markdown/base'

module PuppetStrings::Markdown
  class DataType < Base
    def initialize(registry)
      @template = 'data_type.erb'
      super(registry, 'data type')
    end

    def render
      super(@template)
    end
  end
end
