require 'puppet-strings/yard/handlers/json/base'
require 'puppet-strings/yard/parsers'
require 'puppet-strings/yard/parsers/json/parser'

class PuppetStrings::Yard::Handlers::JSON::TaskHandler < PuppetStrings::Yard::Handlers::JSON::Base
  handles PuppetStrings::Yard::Parsers::JSON::TaskStatement
  namespace_only

  process do
    object = PuppetStrings::Yard::CodeObjects::Task.new(statement)
    register object

    @kind = "Puppet Task #{object.name}."
    @statement = statement

    validate_description
    validate_params
  end

  def validate_description
    log.warn "Missing a description for #{@kind}." if @statement.docstring.empty?
  end

  def validate_params
    unless @statement.parameters.empty?
      @statement.parameters.each do |param, val|
        log.warn "Missing description for param '#{param}' in #{@kind}" if val['description'].nil?
      end
    end
  end
end
