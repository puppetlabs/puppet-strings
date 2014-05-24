# TODO: Decide if supporting 1.8.7 is really worth it.
if RUBY_VERSION < '1.9'
  require 'backports/1.9.1/kernel/require_relative'
end

require_relative 'parser'
require_relative 'handlers'

YARD::Parser::SourceParser.register_parser_type(:puppet,
  Puppetx::Yardoc::YARD::PuppetParser,
  ['pp'])
YARD::Handlers::Processor.register_handler_namespace(:puppet,
  Puppetx::Yardoc::YARD::Handlers)
