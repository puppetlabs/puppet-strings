require 'puppet-strings/yard/handlers/helpers'
require 'puppet-strings/yard/handlers/puppet/base'
require 'puppet-strings/yard/parsers'
require 'puppet-strings/yard/code_objects'

# Implements the handler for Puppet defined types.
class PuppetStrings::Yard::Handlers::Puppet::DefinedTypeHandler < PuppetStrings::Yard::Handlers::Puppet::Base
  handles PuppetStrings::Yard::Parsers::Puppet::DefinedTypeStatement

  process do
    # Register the object
    object = PuppetStrings::Yard::CodeObjects::DefinedType.new(statement)
    register object

    # Log a warning if missing documentation
    log.warn "Missing documentation for Puppet defined type '#{object.name}' at #{statement.file}:#{statement.line}." if object.docstring.empty? && object.tags.empty?

    # Set the parameter types
    set_parameter_types(object)

    # Mark the defined type as public if it doesn't already have an api tag
    object.add_tag YARD::Tags::Tag.new(:api, 'public') unless object.has_tag? :api

    # Warn if a summary longer than 140 characters was provided
    PuppetStrings::Yard::Handlers::Helpers.validate_summary_tag(object) if object.has_tag? :summary
  end
end
