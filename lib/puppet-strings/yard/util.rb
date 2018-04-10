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
      data.gsub!(bad_link.first, "label-#{bad_link.first.capitalize.gsub('-', '+')}")
    end
    data
  end
end
