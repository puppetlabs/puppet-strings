require 'yard/tags/default_factory'
require 'puppet-strings/yard/tags/enum_tag'

class PuppetStrings::Yard::Tags::Factory < YARD::Tags::DefaultFactory

  # Parses tag text and creates a new enum tag type. Modeled after
  # the parse_tag_with_options method in YARD::Tags::DefaultFactory.
  #
  # @param tag_name        the name of the tag to parse
  # @param [String] text   the raw tag text
  # @return [Tag]          a tag object with the tag_name, name, and nested Tag as type
  def parse_tag_with_enums(tag_name, text)
    name, text = *extract_name_from_text(text)
    PuppetStrings::Yard::Tags::EnumTag.new(tag_name, name, parse_tag_with_name(tag_name, text))
  end
end
