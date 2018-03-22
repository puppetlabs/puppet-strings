# Implements the base handler for Puppet language handlers.
class PuppetStrings::Yard::Handlers::Puppet::Base < YARD::Handlers::Base
  # Determine sif the handler handles the given statement.
  # @param statement The statement that was parsed.
  # @return [Boolean] Returns true if the statement is handled by this handler or false if not.
  def self.handles?(statement)
    handlers.any? {|handler| statement.is_a?(handler)}
  end

  protected
  # Sets the parameter tag types for the given code object.
  # This also performs some validation on the parameter tags.
  # @param object The code object to set the parameter tag types for.
  # @return [void]
  def set_parameter_types(object)
    # Ensure there is an actual parameter for each parameter tag
    tags = object.tags(:param)
    tags.each do |tag|
      next if statement.parameters.find { |p| tag.name == p.name }
      log.warn "The @param tag for parameter '#{tag.name}' has no matching parameter at #{statement.file}:#{statement.line}." unless tag.name == 'name' || tag.name == 'title'
    end

    # Assign the types for the parameter
    statement.parameters.each do |parameter|
      tag = tags.find { |t| t.name == parameter.name }
      unless tag
        log.warn "Missing @param tag for parameter '#{parameter.name}' near #{statement.file}:#{statement.line}." unless object.docstring.empty?

        # Add a tag with an empty docstring
        object.add_tag YARD::Tags::Tag.new(:param, '', [parameter.type || 'Any'], parameter.name)
        next
      end

      # Warn if the parameter type and tag types don't match
      log.warn "The type of the @param tag for parameter '#{parameter.name}' does not match the parameter type specification near #{statement.file}:#{statement.line}: ignoring in favor of parameter type information." if parameter.type && tag.types && !tag.types.empty? && parameter.type != tag.types[0]

      if parameter.type
        tag.types = [parameter.type]
      elsif !tag.types
        tag.types = ['Any']
      end
    end
  end
end
