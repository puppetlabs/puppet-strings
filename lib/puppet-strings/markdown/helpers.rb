# frozen_string_literal: true

# Helpers for rendering Markdown
module PuppetStrings::Markdown::Helpers
  # Formats code as either inline or a block.
  #
  # Delimiters are expanded if the code contains the default delimiter.
  #
  # @param [String] code The code to format.
  # @param [Symbol] type The type of the code, e.g. :text, :puppet, or :ruby.
  # @param [String] block_prefix String to insert before if it's a block.
  # @param [String] inline_prefix String to insert before if it's inline.
  # @returns [String] Markdown
  def code_maybe_block(code, type: :puppet, block_prefix: "\n\n", inline_prefix: ' ')
    code_s = code.to_s
    if code_s.include?("\n") || code_s.length > 70
      # Delimiter must be one backtick longer than the longest series of backticks
      #   beginning a line, minimum 3 (with some spaces allowed).
      delim = (code_s.scan(/^ {0,3}``(`+)\s*$/) << '').flatten.max_by(&:length) + '```'
      "#{block_prefix}#{delim}#{type}\n#{code_s}\n#{delim}"
    else
      # Delimeter must be one backtick longer than the longest series of backticks
      #   in the string.
      delim = code_s.scan(/`*/).max_by(&:length) + '`'
      # Padding required if string starts or ends with a backtick
      pad = (code_s[0] == '`' || code_s[-1] == '`') ? ' ' : ''
      "#{inline_prefix}#{delim}#{pad}#{code_s}#{pad}#{delim}"
    end
  end
end
