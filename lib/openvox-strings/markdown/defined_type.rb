# frozen_string_literal: true

require 'openvox-strings/markdown/base'

module OpenvoxStrings::Markdown
  # Generates Markdown for a Puppet Defined Type.
  class DefinedType < Base
    group_name 'Defined types'
    yard_types [:puppet_defined_type]

    def initialize(registry)
      @template = 'classes_and_defines.erb'
      super(registry, 'defined type')
    end

    def render
      super(@template)
    end
  end
end
