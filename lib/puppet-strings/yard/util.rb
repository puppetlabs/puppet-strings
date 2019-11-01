require 'puppet/util'

# The module for various puppet-strings utility helpers.
module PuppetStrings::Yard::Util
  # Trims indentation from trailing whitespace and removes ruby literal quotation
  # syntax `%Q{}` and `%{q}` from parsed strings.
  # @param [String] str The string to scrub.
  # @return [String] A scrubbed string.
  def self.scrub_string(str)
    match = str.match(/^%[Qq]{(.*)}$/m)
    if match
      return Puppet::Util::Docs.scrub(match[1])
    end

    Puppet::Util::Docs.scrub(str)
  end

  # hacksville, usa
  # YARD creates ids in the html with with the style of "label-Module+description", where the markdown
  # we use in the README involves the GitHub-style, which is #module-description. This takes our GitHub-style
  # links and converts them to reference the YARD-style ids.
  # @see https://github.com/octokit/octokit.rb/blob/0f13944e8dbb0210d1e266addd3335c6dc9fe36a/yard/default/layout/html/setup.rb#L5-L14
  # @param [String] data HTML document to convert
  # @return [String] HTML document with links converted
  def self.github_to_yard_links(data)
    data.scan(/href\=\"\#(.+)\"/).each do |bad_link|
      data.gsub!("=\"##{bad_link.first}\"", "=\"#label-#{bad_link.first.capitalize.gsub('-', '+')}\"")
    end
    data
  end

  # Converts a list of tags into an array of hashes.
  # @param [Array] tags List of tags to be converted into an array of hashes.
  # @return [Array] Returns an array of tag hashes.
  def self.tags_to_hashes(tags)
    # Skip over the API tags that are public
    tags.select { |t| (t.tag_name != 'api' || t.text != 'public') }.map do |t|
      next t.to_hash if t.respond_to?(:to_hash)

      tag = { tag_name: t.tag_name }
      # grab nested information for @option and @enum tags
      if tag[:tag_name] == 'option' || tag[:tag_name] == 'enum'
        tag[:opt_name] = t.pair.name
        tag[:opt_text] = t.pair.text
        tag[:opt_types] = t.pair.types if t.pair.types
        tag[:parent] = t.name
      end
      tag[:text] = t.text if t.text
      tag[:types] = t.types if t.types
      tag[:name] = t.name if t.name
      tag
    end
  end

  # Converts a YARD::Docstring (or String) to a docstring hash for JSON output.
  # @param [YARD::Docstring, String] docstring The docstring to convert to a hash.
  # @param [Array] select_tags List of tags to select. Other tags will be filtered out.
  # @return [Hash] Returns a hash representation of the given docstring.
  def self.docstring_to_hash(docstring, select_tags=nil)
    hash = {}
    hash[:text] = docstring

    if docstring.is_a? YARD::Docstring
      tags = tags_to_hashes(docstring.tags.select { |t| select_tags.nil? || select_tags.include?(t.tag_name.to_sym) })

      unless tags.empty?
        hash[:tags] = tags
        #   .sort_by do |tag|
        #   sort_key = tag[:tag_name].dup
        #   sort_key << "-#{tag[:name]}" if tag[:name]
        #   sort_key << "-#{tag[:opt_name]}" if tag[:opt_name]
        #   sort_key
        # end
      end
    end

    hash
  end
end
