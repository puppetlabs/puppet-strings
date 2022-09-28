# frozen_string_literal: true

require 'puppet-strings/markdown/base'

module PuppetStrings::Markdown
  # Generates Markdown for a Puppet Function.
  class Function < Base
    attr_reader :signatures

    def initialize(registry)
      @template = 'function.erb'
      super(registry, 'function')
      @signatures = []
      registry[:signatures].each do |sig|
        @signatures.push(Signature.new(sig))
      end
    end

    def render
      super(@template)
    end

    def type
      t = @registry[:type]
      if %r{ruby4x}.match?(t)
        'Ruby 4.x API'
      elsif %r{ruby3}.match?(t)
        'Ruby 3.x API'
      elsif %r{ruby}.match?(t)
        'Ruby'
      else
        'Puppet Language'
      end
    end

    def error_type(type)
      "`#{type.split(' ')[0]}`"
    end

    def error_text(text)
      text.split(' ').drop(1).join(' ').to_s
    end
  end

  # Implements methods to retrieve information about a function signature.
  class Function::Signature < Base
    def initialize(registry)
      @registry = registry
      super(@registry, 'function signature')
    end

    def signature
      @registry[:signature]
    end
  end
end
