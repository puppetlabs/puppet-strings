class PuppetStrings::Yard::Parsers::JSON::Parser < YARD::Parser::Base
  attr_reader :file, :source

  # Initializes the parser.
  # @param [String] source The source being parsed.
  # @param [String] filename The file name of the file being parsed.
  # @return [void]
  def initialize(source, filename)
    @source = source
    @file = filename
  end

  # Parses the source.
  # @return [void]
  def parse
    begin
      @statements ||= (@visitor.visit(::Puppet::Pops::Parser::Parser.new.parse_string(source)) || []).compact
    rescue ::Puppet::ParseError => ex
      log.error "Failed to parse #{@file}: #{ex.message}"
      @statements = []
    end
    @statements.freeze
    self
  end
end
