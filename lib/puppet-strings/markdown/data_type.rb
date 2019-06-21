require 'puppet-strings/markdown/base'

module PuppetStrings::Markdown
  # This class encapsualtes ruby data types and puppet type aliases
  class DataType < Base
    attr_reader :alias_of

    def initialize(registry)
      @template = 'data_type.erb'
      super(registry, 'data type')
      @alias_of = registry[:alias_of] unless registry[:alias_of].nil?
    end

    def render
      super(@template)
    end
  end
end
