require 'yard/tags/option_tag'

# Implements an enum tag for describing enumerated value data types

class PuppetStrings::Yard::Tags::EnumTag < YARD::Tags::OptionTag
  # Registers the tag with YARD.
  # @return [void]
  def self.register!
    YARD::Tags::Library.define_tag("puppet.enum", :enum, :with_enums)
    YARD::Tags::Library.visible_tags.place(:enum).after(:option)
  end
end
