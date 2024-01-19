# frozen_string_literal: true

# Helpers for rendering Markdown
module PuppetStrings::Markdown::Helpers
  # Formats code as either inline or a block.
  #
  # Note that this does not do any escaping even if the code contains ` or ```.
  #
  # @param [String] code The code to format.
  # @param [Symbol] type The type of the code, e.g. :text, :puppet, or :ruby.
  # @param [String] block_prefix String to insert before if it’s a block.
  # @param [String] inline_prefix String to insert before if it’s inline.
  # @returns [String] Markdown
  def code_maybe_block(code, type: :puppet, block_prefix: "\n\n", inline_prefix: ' ')
    if code.to_s.include?("\n")
      "#{block_prefix}```#{type}\n#{code}\n```"
    else
      "#{inline_prefix}`#{code}`"
    end
  end
end
