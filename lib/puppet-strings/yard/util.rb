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
end
