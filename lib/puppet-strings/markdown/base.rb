require 'puppet-strings'
require 'puppet-strings/json'
require 'puppet-strings/yard'

module PuppetStrings::Markdown
  class Base
    def initialize(registry, component_type)
      @type = component_type
      @registry = registry
      @tags = registry[:docstring][:tags] || []
    end

    def name
      @registry[:name].to_s unless @registry[:name].nil?
    end

    def text
      @registry[:docstring][:text] unless @registry[:docstring][:text].empty?
    end

    def return_val
      @tags.select { |tag| tag[:tag_name] == 'return' }[0][:text] unless @tags.select { |tag| tag[:tag_name] == 'return' }[0].nil?
    end

    def return_type
      @tags.select { |tag| tag[:tag_name] == 'return' }[0][:types][0] unless @tags.select { |tag| tag[:tag_name] == 'return' }[0].nil?
    end

    # @return [String] text from @since tag
    def since
      @tags.select { |tag| tag[:tag_name] == 'since' }[0][:text] unless @tags.select { |tag| tag[:tag_name] == 'since' }[0].nil?
    end

    # return [Array] array of @see tag hashes
    def see
      @tags.select { |tag| tag[:tag_name] == 'see' } unless @tags.select { |tag| tag[:tag_name] == 'see' }[0].nil?
    end

    # return [String] text from @summary tag
    def summary
      @tags.select { |tag| tag[:tag_name] == 'summary' }[0][:text] unless @tags.select { |tag| tag[:tag_name] == 'summary' }[0].nil?
    end

    # return [Array] array of parameter tag hashes
    def params
      @tags.select { |tag| tag[:tag_name] == 'param' } unless @tags.select { |tag| tag[:tag_name] == 'param' }[0].nil?
    end

    # return [Array] array of example tag hashes
    def examples
      @tags.select { |tag| tag[:tag_name] == 'example' } unless @tags.select { |tag| tag[:tag_name] == 'example' }[0].nil?
    end

    def toc_info
      {
        name: name.to_s,
        link: link,
        desc: summary || @registry[:docstring][:text].gsub("\n", ". ")
      }
    end

    def link
      name.delete('::').strip.gsub(' ','-').downcase
    end

    def defaults
      @registry[:defaults] unless @registry[:defaults].nil?
    end

    def value_string(value)
      to_symbol = %w[undef true false]
      if to_symbol.include? value
        return "`#{value}`"
      else
        return value
      end
    end

    def render(template)
      file = File.join(File.dirname(__FILE__),"templates/#{template}")
      ERB.new(File.read(file), nil, '-').result(binding)
    end
  end
end
