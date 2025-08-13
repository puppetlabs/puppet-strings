# frozen_string_literal: true

require 'openvox-strings/yard/handlers/helpers'
require 'openvox-strings/yard/handlers/puppet/base'
require 'openvox-strings/yard/parsers'
require 'openvox-strings/yard/code_objects'

# Implements the handler for Puppet classes.
class OpenvoxStrings::Yard::Handlers::Puppet::FunctionHandler < OpenvoxStrings::Yard::Handlers::Puppet::Base
  handles OpenvoxStrings::Yard::Parsers::Puppet::FunctionStatement

  process do
    # Register the object
    object = OpenvoxStrings::Yard::CodeObjects::Function.new(statement.name, OpenvoxStrings::Yard::CodeObjects::Function::PUPPET)
    object.source = statement.source
    object.source_type = parser.parser_type
    register object

    # Log a warning if missing documentation
    log.warn "Missing documentation for Puppet function '#{object.name}' at #{statement.file}:#{statement.line}." if object.docstring.empty? && object.tags.empty?

    # Set the parameter tag types
    set_parameter_types(object)

    # Add a return tag
    add_return_tag(object, statement.type)

    # Set the parameters on the object
    object.parameters = statement.parameters.map { |p| [p.name, p.value] }

    # Mark the class as public if it doesn't already have an api tag
    object.add_tag YARD::Tags::Tag.new(:api, 'public') unless object.has_tag? :api

    # Warn if a summary longer than 140 characters was provided
    OpenvoxStrings::Yard::Handlers::Helpers.validate_summary_tag(object) if object.has_tag? :summary
  end

  private

  def add_return_tag(object, type = nil)
    tag = object.tag(:return)
    if tag
      log.warn "Documented return type does not match return type in function definition near #{statement.file}:#{statement.line}." if type && tag.types && tag.types.first && (type != tag.types.first)

      tag.types = type ? [type] : tag.types || ['Any']
      return
    end
    log.warn "Missing @return tag near #{statement.file}:#{statement.line}."
    type ||= 'Any'
    object.add_tag YARD::Tags::Tag.new(:return, '', type)
  end
end
