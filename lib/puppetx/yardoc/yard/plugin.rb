# TODO: Decide if supporting 1.8.7 is really worth it.
if RUBY_VERSION < '1.9'
  require 'backports/1.9.1/kernel/require_relative'
end

require 'puppet'

require_relative 'monkey_patches'
require_relative 'parser'
require_relative 'handlers'

YARD::Parser::SourceParser.register_parser_type(:puppet,
  Puppetx::Yardoc::YARD::PuppetParser,
  ['pp'])
YARD::Handlers::Processor.register_handler_namespace(:puppet,
  Puppetx::Yardoc::YARD::Handlers)

# FIXME: Might not be the best idea to have the template code on the Ruby
# LOAD_PATH as the contents of this directory really aren't library code.
YARD::Templates::Engine.register_template_path(File.join(
  File.dirname(__FILE__),
  'templates'))
