require 'puppet-strings/yard/handlers/helpers'
require 'puppet-strings/yard/handlers/puppet/base'
require 'puppet-strings/yard/parsers'
require 'puppet-strings/yard/code_objects'

# Implements the handler for Puppet classes.
class PuppetStrings::Yard::Handlers::Puppet::FunctionHandler < PuppetStrings::Yard::Handlers::Puppet::Base
  handles PuppetStrings::Yard::Parsers::Puppet::FunctionStatement

  process do
    # Register the object
    object = PuppetStrings::Yard::CodeObjects::Function.new(statement.name, PuppetStrings::Yard::CodeObjects::Function::PUPPET)
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
    PuppetStrings::Yard::Handlers::Helpers.validate_summary_tag(object) if object.has_tag? :summary
  end

  private
  def add_return_tag(object, type=nil)
    tag = object.tag(:return)
    if tag
      if (type && tag.types.first) && (type != tag.types.first)
        log.warn "Documented return type does not match return type in function definition near #{statement.file}:#{statement.line}."
      end

      tag.types = type ? [type] : tag.types || ['Any']
      return
    end
    log.warn "Missing @return tag near #{statement.file}:#{statement.line}."
    type = type || 'Any'
    object.add_tag YARD::Tags::Tag.new(:return, '', type)
  end
end
