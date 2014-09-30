require 'puppet'
require 'puppetx/puppetlabs/strings/yard/monkey_patches'
require 'puppetx/puppetlabs/strings/yard/parser'
require 'puppetx/puppetlabs/strings'

YARD::Parser::SourceParser.register_parser_type(:puppet,
  Puppetx::PuppetLabs::Strings::YARD::PuppetParser,
  ['pp'])
YARD::Handlers::Processor.register_handler_namespace(:puppet,
  Puppetx::PuppetLabs::Strings::YARD::Handlers)

# FIXME: Might not be the best idea to have the template code on the Ruby
# LOAD_PATH as the contents of this directory really aren't library code.
YARD::Templates::Engine.register_template_path(File.join(
  File.dirname(__FILE__),
  'templates'))
