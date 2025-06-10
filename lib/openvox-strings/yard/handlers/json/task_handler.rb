# frozen_string_literal: true

require 'openvox-strings/yard/handlers/json/base'
require 'openvox-strings/yard/parsers'
require 'openvox-strings/yard/parsers/json/parser'

# Implements the handler for JSON task metadata.
class OpenvoxStrings::Yard::Handlers::JSON::TaskHandler < OpenvoxStrings::Yard::Handlers::JSON::Base
  handles OpenvoxStrings::Yard::Parsers::JSON::TaskStatement
  namespace_only

  process do
    object = OpenvoxStrings::Yard::CodeObjects::Task.new(statement)
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
    return if @statement.parameters.empty?

    @statement.parameters.each do |param, val|
      log.warn "Missing description for param '#{param}' in #{@kind}" if val['description'].nil?
    end
  end
end
