require 'ripper'

# Implements the base handler for Ruby language handlers.
class PuppetStrings::Yard::Handlers::Ruby::Base < YARD::Handlers::Ruby::Base
  # A regular expression for detecting the start of a Ruby heredoc.
  # Note: the first character of the heredoc start may have been cut off by YARD.
  HEREDOC_START = /^<?<[\-~]?['"]?(\w+)['"]?[^\n]*[\n]?/

  protected
  # Converts the given Ruby AST node to a string representation.
  # @param node The Ruby AST node to convert.
  # @return [String] Returns a string representation of the node or nil if a string representation was not possible.
  def node_as_string(node)
    return nil unless node
    case node.type
    when :symbol, :symbol_literal
      node.source[1..-1]
    when :label
      node.source[0..-2]
    when :dyna_symbol
      content = node.jump(:tstring_content)
      content.nil? ? node.source : content.source
    when :string_literal
      content = node.jump(:tstring_content)
      return content.source if content != node

      # This attempts to work around a bug in YARD (https://github.com/lsegal/yard/issues/779)
      # Check to see if the string source appears to have a heredoc open tag (or "most" of one)
      # If so, remove the first line and the last line (if the latter contains the heredoc tag)
      source = node.source
      if source =~ HEREDOC_START
        lines = source.split("\n")
        source = lines[1..(lines.last.include?($1[0..-2]) ? -2 : -1)].join("\n") if lines.size > 1
      end

      source
    when :regexp_literal
      node.source
    end
  end

  def get_name(statementobject, statementtype)
    parameters = statementobject.parameters(false)
    raise YARD::Parser::UndocumentableError, "Expected at least one parameter to #{statementtype} at #{statementobject.file}:#{statementobject.line}." if parameters.empty?
    name = node_as_string(parameters.first)
    raise YARD::Parser::UndocumentableError, "Expected a symbol or string literal for first parameter but found '#{parameters.first.type}' at #{statement.file}:#{statement.line}." unless name
    name
  end
end
