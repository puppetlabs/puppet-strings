# frozen_string_literal: true

require 'openvox-strings/yard/handlers/helpers'
require 'openvox-strings/yard/handlers/puppet/base'
require 'openvox-strings/yard/parsers'
require 'openvox-strings/yard/code_objects'

# Implements the handler for Puppet defined types.
class OpenvoxStrings::Yard::Handlers::Puppet::DefinedTypeHandler < OpenvoxStrings::Yard::Handlers::Puppet::Base
  handles OpenvoxStrings::Yard::Parsers::Puppet::DefinedTypeStatement

  process do
    # Register the object
    object = OpenvoxStrings::Yard::CodeObjects::DefinedType.new(statement)
    register object

    # Log a warning if missing documentation
    log.warn "Missing documentation for Puppet defined type '#{object.name}' at #{statement.file}:#{statement.line}." if object.docstring.empty? && object.tags.empty?

    # Set the parameter types
    set_parameter_types(object)

    # Mark the defined type as public if it doesn't already have an api tag
    object.add_tag YARD::Tags::Tag.new(:api, 'public') unless object.has_tag? :api

    # Warn if a summary longer than 140 characters was provided
    OpenvoxStrings::Yard::Handlers::Helpers.validate_summary_tag(object) if object.has_tag? :summary
  end
end
