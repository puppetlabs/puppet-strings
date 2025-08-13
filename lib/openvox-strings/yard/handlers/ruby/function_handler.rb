# frozen_string_literal: true

require 'openvox-strings/yard/handlers/helpers'
require 'openvox-strings/yard/handlers/ruby/base'
require 'openvox-strings/yard/code_objects'
require 'openvox-strings/yard/util'

# Implements the handler for Puppet functions written in Ruby.
class OpenvoxStrings::Yard::Handlers::Ruby::FunctionHandler < OpenvoxStrings::Yard::Handlers::Ruby::Base
  # Represents the list of Puppet 4.x function API methods to support.
  DISPATCH_METHOD_NAMES = %w[
    param
    required_param
    optional_param
    repeated_param
    optional_repeated_param
    required_repeated_param
    block_param
    required_block_param
    optional_block_param
    return_type
  ].freeze

  namespace_only
  handles method_call(:create_function)
  handles method_call(:newfunction)

  process do
    # Only accept calls to Puppet::Functions (4.x) or Puppet::Parser::Functions (3.x)
    # When `newfunction` is separated from the Puppet::Parser::Functions module name by a
    # newline, YARD ignores the namespace and uses `newfunction` as the source of the
    # first statement.
    return unless statement.count > 1

    module_name = statement[0].source
    return unless ['Puppet::Functions', 'Puppet::Parser::Functions', 'newfunction'].include?(module_name)

    # Create and register the function object
    is_3x = ['Puppet::Parser::Functions', 'newfunction'].include?(module_name)
    object = OpenvoxStrings::Yard::CodeObjects::Function.new(
      get_name(statement, 'Puppet::Functions.create_function'),
      is_3x ? OpenvoxStrings::Yard::CodeObjects::Function::RUBY_3X : OpenvoxStrings::Yard::CodeObjects::Function::RUBY_4X,
    )
    object.source = statement
    register object

    # For 3x, parse the doc parameter for the docstring
    # This must be done after the `register` call above because `register` always uses the statement's docstring
    if is_3x
      docstring = get_3x_docstring(object.name)
      register_docstring(object, docstring, nil) if docstring

      # Default any typeless param tag to 'Any'
      object.tags(:param).each do |tag|
        tag.types = ['Any'] unless tag.types && !tag.types.empty?
      end

      # Populate the parameters and the return tag
      object.parameters = object.tags(:param).map { |p| [p.name, nil] }
      add_return_tag(object, statement.file, statement.line)
    else
      # For 4x, auto generate tags based on dispatch docstrings
      add_tags(object)
    end

    # Mark the function as public if it doesn't already have an api tag
    object.add_tag YARD::Tags::Tag.new(:api, 'public') unless object.has_tag? :api

    # Warn if a summary longer than 140 characters was provided
    OpenvoxStrings::Yard::Handlers::Helpers.validate_summary_tag(object) if object.has_tag? :summary
  end

  private

  def add_tags(object)
    log.warn "Missing documentation for Puppet function '#{object.name}' at #{statement.file}:#{statement.line}." if object.docstring.empty? && object.tags.empty?

    unless object.tags(:param).empty?
      log.warn "The docstring for Puppet 4.x function '#{object.name}' " \
               "contains @param tags near #{object.file}:#{object.line}: parameter " \
               'documentation should be made on the dispatch call.'
    end

    unless object.tags(:return).empty?
      log.warn "The docstring for Puppet 4.x function '#{object.name}' " \
               "contains @return tags near #{object.file}:#{object.line}: return " \
               'value documentation should be made on the dispatch call.'
    end

    unless object.tags(:overload).empty?
      log.warn "The docstring for Puppet 4.x function '#{object.name}' " \
               "contains @overload tags near #{object.file}:#{object.line}: overload " \
               'tags are automatically generated from the dispatch calls.'
    end

    # Delete any existing param/return/overload tags
    object.docstring.delete_tags(:param)
    object.docstring.delete_tags(:return)
    object.docstring.delete_tags(:overload)

    block = statement.block
    return unless block && block.count >= 2

    # Get the unqualified name of the Puppet function
    unqualified_name = object.name.to_s.split('::').last

    # Walk the block statements looking for dispatch calls and methods with the same name as the Puppet function
    default = nil
    block[1].children.each do |node|
      if node.is_a?(YARD::Parser::Ruby::MethodCallNode)
        add_overload_tag(object, node)
      elsif node.is_a?(YARD::Parser::Ruby::MethodDefinitionNode)
        default = node if node.method_name && node.method_name.source == unqualified_name
      end
    end

    # Create an overload for the default method if there is one
    overloads = object.tags(:overload)
    if overloads.empty? && default
      add_method_overload(object, default)
      overloads = object.tags(:overload)
    end

    # If there's only one overload, move the tags to the object itself
    return unless overloads.length == 1

    overload = overloads.first
    object.parameters = overload.parameters
    object.add_tag(*overload.tags)
    object.docstring.delete_tags(:overload)
  end

  def add_overload_tag(object, node)
    # Look for a call to a dispatch method with a block
    return unless node.is_a?(YARD::Parser::Ruby::MethodCallNode) &&
                  node.method_name &&
                  node.method_name.source == 'dispatch' &&
                  node.parameters(false).count == 1 &&
                  node.block &&
                  node.block.count >= 2

    overload_tag = OpenvoxStrings::Yard::Tags::OverloadTag.new(object.name, node.docstring || '')
    param_tags = overload_tag.tags(:param)

    block = nil
    node.block[1].children.each do |child|
      next unless child.is_a?(YARD::Parser::Ruby::MethodCallNode) && child.method_name

      method_name = child.method_name.source
      next unless DISPATCH_METHOD_NAMES.include?(method_name)

      if method_name == 'return_type'
        # Add a return tag if missing
        overload_tag.add_tag YARD::Tags::Tag.new(:return, '', 'Any') if overload_tag.tag(:return).nil?

        overload_tag.tag(:return).types = [node_as_string(child.parameters[0])]
        next
      end

      # Check for block
      if method_name.include?('block')
        if block
          log.warn "A duplicate block parameter was found for Puppet function '#{object.name}' at #{child.file}:#{child.line}."
          next
        end

        # Store the block; needs to be appended last
        block = child
        next
      end

      # Ensure two parameters to parameter definition
      parameters = child.parameters(false)
      unless parameters.count == 2
        log.warn "Expected 2 arguments to '#{method_name}' call at #{child.file}:#{child.line}: parameter information may not be correct."
        next
      end

      add_param_tag(
        overload_tag,
        param_tags,
        node_as_string(parameters[1]),
        child.file,
        child.line,
        node_as_string(parameters[0]),
        nil, # TODO: determine default from corresponding Ruby method signature?
        method_name.include?('optional'),
        method_name.include?('repeated'),
      )
    end

    # Handle the block parameter after others so it appears last in the list
    if block
      parameters = block.parameters(false)
      if parameters.empty?
        name = 'block'
        type = 'Callable'
      elsif parameters.count == 1
        name = node_as_string(parameters[0])
        type = 'Callable'
      elsif parameters.count == 2
        type = node_as_string(parameters[0])
        name = node_as_string(parameters[1])
      else
        log.warn "Unexpected number of arguments to block definition at #{block.file}:#{block.line}."
      end

      if name && type
        add_param_tag(
          overload_tag,
          param_tags,
          name,
          block.file,
          block.line,
          type,
          nil, # TODO: determine default from corresponding Ruby method signature?
          block.method_name.source.include?('optional'),
          false, # Not repeated
          true, # Is block
        )
      end
    end

    # Add a return tag if missing
    add_return_tag(overload_tag, node.file, node.line)

    # Validate that tags have parameters
    validate_overload(overload_tag, node.file, node.line)

    object.add_tag overload_tag
  end

  def add_method_overload(object, node)
    overload_tag = OpenvoxStrings::Yard::Tags::OverloadTag.new(object.name, node.docstring || '')
    param_tags = overload_tag.tags(:param)

    parameters = node.parameters

    # Populate the required parameters
    params = parameters.unnamed_required_params
    params&.each do |parameter|
      add_param_tag(
        overload_tag,
        param_tags,
        parameter.source,
        parameter.file,
        parameter.line,
      )
    end

    # Populate the optional parameters
    params = parameters.unnamed_optional_params
    params&.each do |parameter|
      add_param_tag(
        overload_tag,
        param_tags,
        parameter[0].source,
        parameter.file,
        parameter.line,
        nil,
        parameter[1].source,
        true,
      )
    end

    # Populate the splat parameter
    param = parameters.splat_param
    if param
      add_param_tag(
        overload_tag,
        param_tags,
        param.source,
        param.file,
        param.line,
        nil,
        nil,
        false,
        true,
      )
    end

    # Populate the block parameter
    param = parameters.block_param
    if param
      add_param_tag(
        overload_tag,
        param_tags,
        param.source,
        param.file,
        param.line,
        nil,
        nil,
        false,
        false,
        true,
      )
    end

    # Add a return tag if missing
    add_return_tag(overload_tag, node.file, node.line)

    # Validate that tags have parameters
    validate_overload(overload_tag, node.file, node.line)

    object.add_tag overload_tag
  end

  def add_param_tag(object, tags, name, file, line, type = nil, default = nil, optional = false, repeated = false, block = false)
    tag = tags.find { |t| t.name == name } if tags
    log.warn "Missing @param tag for parameter '#{name}' near #{file}:#{line}." unless tag || object.docstring.all.empty?

    if type && tag && tag.types && !tag.types.empty?
      log.warn "The @param tag for parameter '#{name}' should not contain a " \
               "type specification near #{file}:#{line}: ignoring in favor of " \
               'dispatch type information.'
    end

    if repeated
      name = "*#{name}"
    elsif block
      name = "&#{name}"
    end

    type ||= tag&.types ? tag.type : 'Any'
    type = "Optional[#{type}]" if optional

    object.parameters << [name, to_puppet_literal(default)]

    if tag
      tag.name = name
      tag.types = [type]
    else
      object.add_tag YARD::Tags::Tag.new(:param, '', type, name)
    end
  end

  def add_return_tag(object, file, line)
    tag = object.tag(:return)
    if tag
      tag.types = ['Any'] unless tag.types
      return
    end
    log.warn "Missing @return tag near #{file}:#{line}."
    object.add_tag YARD::Tags::Tag.new(:return, '', 'Any')
  end

  def validate_overload(overload, file, line)
    # Validate that tags have matching parameters
    overload.tags(:param).each do |tag|
      next if overload.parameters.find { |p| tag.name == p[0] }

      log.warn "The @param tag for parameter '#{tag.name}' has no matching parameter at #{file}:#{line}."
    end
  end

  def get_3x_docstring(name)
    parameters = statement.parameters(false)
    if parameters.count >= 2
      parameters[1].each do |kvp|
        next unless kvp.count == 2
        next unless node_as_string(kvp[0]) == 'doc'

        docstring = node_as_string(kvp[1])

        log.error "Failed to parse docstring for 3.x Puppet function '#{name}' near #{statement.file}:#{statement.line}." and return nil unless docstring

        return OpenvoxStrings::Yard::Util.scrub_string(docstring)
      end
    end

    # Log a warning for missing docstring
    log.warn "Missing documentation for Puppet function '#{name}' at #{statement.file}:#{statement.line}."
    nil
  end

  def to_puppet_literal(literal)
    case literal
    when 'nil'
      'undef'
    when ':default'
      'default'
    else
      literal
    end
  end
end
