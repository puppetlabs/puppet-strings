# frozen_string_literal: true

require 'puppet-strings/markdown/base'

module PuppetStrings::Markdown
  # This class encapsualtes ruby data types and puppet type aliases
  class DataType < Base
    attr_reader :alias_of, :functions

    group_name 'Data types'
    yard_types %i[puppet_data_type puppet_data_type_alias]

    def initialize(registry)
      @template = 'data_type.erb'
      super(registry, 'data type')
      @alias_of = registry[:alias_of] unless registry[:alias_of].nil?
      @functions = @registry[:functions]&.map { |func| DataType::Function.new(func) }
    end

    def render
      super(@template)
    end
  end

  # Generates Markdown for a Puppet Function.
  class DataType::Function < Base
    def initialize(registry)
      super(registry, 'data_type_function')
    end

    def render
      super('data_type_function.erb')
    end

    def signature
      @registry[:signature]
    end
  end
end
