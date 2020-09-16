# frozen_string_literal: true

require 'puppet-strings/markdown/base'

module PuppetStrings::Markdown
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
      if /ruby4x/.match?(t)
        "Ruby 4.x API"
      elsif /ruby3/.match?(t)
        "Ruby 3.x API"
      elsif /ruby/.match?(t)
        "Ruby"
      else
        "Puppet Language"
      end
    end

    def error_type(type)
      "`#{type.split(' ')[0]}`"
    end

    def error_text(text)
      "#{text.split(' ').drop(1).join(' ')}"
    end
  end

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
