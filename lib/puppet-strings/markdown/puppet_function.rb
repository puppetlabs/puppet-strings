require 'puppet-strings/markdown/base'

module PuppetStrings::Markdown
  class PuppetFunction < Base
    attr_reader :signatures

    def initialize(registry)
      @template = 'puppet_function.erb'
      super(registry, 'function')
      @signatures = []
      registry[:signatures].each do |sig|
        @signatures.push(Signature.new(sig))
      end
    end

    def render
      super(@template)
    end
  end

  class PuppetFunction::Signature < Base
    def initialize(registry)
      @registry = registry
      super(@registry, 'function signature')
    end

    def signature
      @registry[:signature]
    end
  end
end
