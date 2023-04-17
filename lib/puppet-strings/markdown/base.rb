# frozen_string_literal: true

require 'puppet-strings'
require 'puppet-strings/json'
require 'puppet-strings/yard'
require 'puppet-strings/markdown/helpers'

# Implements classes that make elements in a YARD::Registry hash easily accessible for template.
module PuppetStrings::Markdown
  # This class makes elements in a YARD::Registry hash easily accessible for templates.
  #
  # Here's an example hash:
  # {:name=>:klass,
  # :file=>"(stdin)",
  # :line=>16,
  # :inherits=>"foo::bar",
  # :docstring=>
  #  {:text=>"An overview for a simple class.",
  #   :tags=>
  #    [{:tag_name=>"summary", :text=>"A simple class."},
  #     {:tag_name=>"since", :text=>"1.0.0"},
  #     {:tag_name=>"see", :name=>"www.puppet.com"},
  #     {:tag_name=>"deprecated", :text=>"No longer supported and will be removed in a future release"},
  #     {:tag_name=>"example",
  #      :text=>
  #       "class { 'klass':\n" +
  #       "  param1 => 1,\n" +
  #       "  param3 => 'foo',\n" +
  #       "}",
  #      :name=>"This is an example"},
  #     {:tag_name=>"author", :text=>"eputnam"},
  #     {:tag_name=>"option", :name=>"opts"},
  #     {:tag_name=>"raise", :text=>"SomeError"},
  #     {:tag_name=>"param",
  #      :text=>"First param.",
  #      :types=>["Integer"],
  #      :name=>"param1"},
  #     {:tag_name=>"param",
  #      :text=>"Second param.",
  #      :types=>["Any"],
  #      :name=>"param2"},
  #     {:tag_name=>"param",
  #      :text=>"Third param.",
  #      :types=>["String"],
  #      :name=>"param3"}]},
  # :defaults=>{"param1"=>"1", "param2"=>"undef", "param3"=>"'hi'"},
  # :source=>
  #  "class klass (\n" +
  #  "  Integer $param1 = 1,\n" +
  #  "  $param2 = undef,\n" +
  #  "  String $param3 = 'hi'\n" +
  #  ") inherits foo::bar {\n" +
  #  "}"}
  class Base
    # Helpers for ERB templates
    include PuppetStrings::Markdown::Helpers

    # Set or return the name of the group
    #
    # @param [Optional[String]] Name of the group to set
    # @return [String] Name of the group
    def self.group_name(name = nil)
      @group_name = name if name
      @group_name
    end

    # Set or return the types registered with YARD
    #
    # @param [Optional[Array[Symbol]]] Array of symbols registered with YARD to set
    # @return [Array[Symbol]] Array of symbols registered with YARD
    def self.yard_types(types = nil)
      @yard_types = types if types
      @yard_types
    end

    # @return [Array] list of items
    def self.items
      yard_types
        .flat_map { |type| YARD::Registry.all(type) }
        .sort_by(&:name)
        .map(&:to_hash)
        .map { |i| new(i) }
    end

    def initialize(registry, component_type)
      @type = component_type
      @registry = registry
      @tags = registry[:docstring][:tags] || []
    end

    # generate 1:1 tag methods
    # e.g. {:tag_name=>"author", :text=>"eputnam"}
    { return_val: 'return',
      since: 'since',
      summary: 'summary',
      note: 'note',
      todo: 'todo',
      deprecated: 'deprecated' }.each do |method_name, tag_name|
      # @return [String] unless the tag is nil or the string.empty?
      define_method method_name do
        @tags.find { |tag| tag[:tag_name] == tag_name && !tag[:text].empty? }[:text] if @tags.any? { |tag| tag[:tag_name] == tag_name && !tag[:text].empty? }
      end
    end

    # @return [String] top-level name
    def name
      @registry[:name]&.to_s
    end

    # @return [String] 'Overview' text (untagged text)
    def text
      @registry[:docstring][:text] unless @registry[:docstring][:text].empty?
    end

    # @return [String] data type of return value
    def return_type
      @tags.find { |tag| tag[:tag_name] == 'return' }[:types][0] if @tags.any? { |tag| tag[:tag_name] == 'return' }
    end

    # @return [String] text from @since tag
    def since
      @tags.find { |tag| tag[:tag_name] == 'since' }[:text] if @tags.any? { |tag| tag[:tag_name] == 'since' }
    end

    # @return [Array] @see tag hashes
    def see
      select_tags('see')
    end

    # @return [Array] parameter tag hashes
    def params
      tags = @tags.select { |tag| tag[:tag_name] == 'param' }.map do |param|
        param[:link] = clean_link("$#{name}::#{param[:name]}")
        param
      end
      tags.empty? ? nil : tags
    end

    # @return [Array] example tag hashes
    def examples
      select_tags('example')
    end

    # @return [Array] raise tag hashes
    def raises
      select_tags('raise')
    end

    # @return [Array] option tag hashes
    def options
      select_tags('option')
    end

    # @return [Array] enum tag hashes
    def enums
      select_tags('enum')
    end

    # @param parameter_name
    #   parameter name to match to option tags
    # @return [Array] option tag hashes that have a parent parameter_name
    def options_for_param(parameter_name)
      opts_for_p = options.select { |o| o[:parent] == parameter_name } unless options.nil?
      opts_for_p unless opts_for_p.nil? || opts_for_p.empty?
    end

    # @param parameter_name
    #   parameter name to match to enum tags
    # @return [Array] enum tag hashes that have a parent parameter_name
    def enums_for_param(parameter_name)
      enums_for_p = enums.select { |e| e[:parent] == parameter_name } unless enums.nil?
      enums_for_p unless enums_for_p.nil? || enums_for_p.empty?
    end

    # @return [Hash] any defaults found for the component
    def defaults
      @registry[:defaults] unless @registry[:defaults].nil?
    end

    # @return [Hash] information needed for the table of contents
    def toc_info
      {
        name: name.to_s,
        link: link,
        desc: summary || @registry[:docstring][:text][0..140].tr("\n", ' '),
        private: private?
      }
    end

    # @return [String] makes the component name suitable for a GitHub markdown link
    def link
      clean_link(name)
    end

    def private?
      @tags.any? { |tag| tag[:tag_name] == 'api' && tag[:text] == 'private' }
    end

    def word_wrap(text, line_width: 120, break_sequence: "\n")
      return unless text

      text.split("\n").map! { |line|
        line.length > line_width ? line.gsub(/(.{1,#{line_width}})(\s+|$)/, "\\1#{break_sequence}").strip : line
      } * break_sequence
    end

    # @return [String] full markdown rendering of a component
    def render(template)
      file = File.join(File.dirname(__FILE__), 'templates', template)
      begin
        PuppetStrings::Markdown.erb(file).result(binding)
      rescue StandardError => e
        raise "Processing #{@registry[:file]}:#{@registry[:line]} with #{file} => #{e}"
      end
    end

    private

    def select_tags(name)
      tags = @tags.select { |tag| tag[:tag_name] == name }
      tags.empty? ? nil : tags
    end

    # Convert an input into a string appropriate for an anchor name.
    #
    # This converts any character not suitable for an id attribute into a '-'. Generally we're running this on Puppet identifiers for types and
    # variables, so we only need to worry about the special characters ':' and '$'. With namespaces Puppet variables this should always be produce a
    # unique result from a unique input, since ':' only appears in pairs, '$' only appears at the beginning, and '-' never appears.
    #
    # @param [String] the input to convert
    # @return [String] the anchor-safe string
    def clean_link(input)
      input.tr('^a-zA-Z0-9_-', '-')
    end
  end
end
