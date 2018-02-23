require 'puppet-strings/yard/handlers/json/base'
require 'puppet-strings/yard/parsers'
require 'puppet-strings/yard/parsers/json/parser'

class PuppetStrings::Yard::Handlers::JSON::TaskHandler < PuppetStrings::Yard::Handlers::JSON::Base
  handles PuppetStrings::Yard::Parsers::JSON::TaskStatement
  namespace_only

  process do
    object = PuppetStrings::Yard::CodeObjects::Task.new(statement)
    register object
  end
end
