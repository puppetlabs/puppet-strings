# Implements a summary tag for general purpose short descriptions

class PuppetStrings::Yard::Tags::SummaryTag < YARD::Tags::Tag
  # Registers the tag with YARD.
  # @return [void]
  def self.register!
    YARD::Tags::Library.define_tag("puppet.summary", :summary)
  end
end
