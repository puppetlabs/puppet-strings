require_relative 'parser'
require_relative 'handlers'

YARD::Parser::SourceParser.register_parser_type(:puppet,
  Puppetx::Yardoc::YARD::PuppetParser,
  ['pp'])
YARD::Handlers::Processor.register_handler_namespace(:puppet,
  Puppetx::Yardoc::YARD::Handlers)
