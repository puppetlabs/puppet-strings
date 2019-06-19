require 'puppet-strings/yard/handlers/ruby/base'

class PuppetStrings::Yard::Handlers::Ruby::TypeBase < PuppetStrings::Yard::Handlers::Ruby::Base
  protected
  def get_type_yard_object(name)
    #Have to guess the path - if we create the object to get the true path from the code,
    #it also shows up in the .at call - self registering?
    guess_path = "puppet_types::#{name}"
    object = YARD::Registry.at(guess_path)

    return object unless object.nil?

    #Didn't find, create instead
    object = PuppetStrings::Yard::CodeObjects::Type.new(name)
    register object
    object
  end

  def find_docstring(node, kind)
    # Walk the tree searching for assignments or calls to desc/doc=
    node.traverse do |child|
      if child.type == :assign
        ivar = child.jump(:ivar)
        next unless ivar != child && ivar.source == '@doc'
        docstring = node_as_string(child[1])
        log.error "Failed to parse docstring for #{kind} near #{child.file}:#{child.line}." and return nil unless docstring
        return PuppetStrings::Yard::Util.scrub_string(docstring)
      elsif child.is_a?(YARD::Parser::Ruby::MethodCallNode)
        # Look for a call to a dispatch method with a block
        next unless child.method_name &&
                (child.method_name.source == 'desc' || child.method_name.source == 'doc=') &&
                child.parameters(false).count == 1

        docstring = node_as_string(child.parameters[0])
        log.error "Failed to parse docstring for #{kind} near #{child.file}:#{child.line}." and return nil unless docstring
        return PuppetStrings::Yard::Util.scrub_string(docstring)
      end
    end
    log.warn "Missing a description for #{kind} at #{node.file}:#{node.line}."
    nil
  end

  def create_parameter(name, node)
    parameter = PuppetStrings::Yard::CodeObjects::Type::Parameter.new(name, find_docstring(node, "Puppet resource parameter '#{name}'"))
    set_values(node, parameter)
    parameter
  end

  def create_property(name, node)
    property = PuppetStrings::Yard::CodeObjects::Type::Property.new(name, find_docstring(node, "Puppet resource property '#{name}'"))
    set_values(node, property)
    property
  end

  def set_values(node, object)
    return unless node.block && node.block.count >= 2

    node.block[1].children.each do |child|
      next unless child.is_a?(YARD::Parser::Ruby::MethodCallNode) && child.method_name

      method_name = child.method_name.source
      parameters = child.parameters(false)

      if method_name == 'newvalue'
        next unless parameters.count >= 1
        object.add(node_as_string(parameters[0]) || parameters[0].source)
      elsif method_name == 'newvalues'
        parameters.each do |p|
          object.add(node_as_string(p) || p.source)
        end
      elsif method_name == 'aliasvalue'
        next unless parameters.count >= 2
        object.alias(node_as_string(parameters[0]) || parameters[0].source, node_as_string(parameters[1]) || parameters[1].source)
      elsif method_name == 'defaultto'
        next unless parameters.count >= 1
        object.default = node_as_string(parameters[0]) || parameters[0].source
      elsif method_name == 'isnamevar'
        object.isnamevar = true
      elsif method_name == 'defaultvalues' && object.name == 'ensure'
        object.add('present')
        object.add('absent')
        object.default = 'present'
      end
    end

    parameters = node.parameters(false)

    if parameters.count >= 2
      kvps = parameters[1].find_all { |kvp| kvp.count == 2 }
      required_features_kvp = kvps.find { |kvp| node_as_string(kvp[0]) == 'required_features' }
      object.required_features = node_as_string(required_features_kvp[1]) unless required_features_kvp.nil?
    end

    if object.is_a? PuppetStrings::Yard::CodeObjects::Type::Parameter
      # Process the options for parameter base types
      if parameters.count >= 2
        parameters[1].each do |kvp|
          next unless kvp.count == 2
          next unless node_as_string(kvp[0]) == 'parent'
          if kvp[1].source == 'Puppet::Parameter::Boolean'
            object.add('true') unless object.values.include? 'true' # rubocop:disable Performance/InefficientHashSearch Not supported on Ruby 2.1
            object.add('false') unless object.values.include? 'false' # rubocop:disable Performance/InefficientHashSearch Not supported on Ruby 2.1
            object.add('yes') unless object.values.include? 'yes' # rubocop:disable Performance/InefficientHashSearch Not supported on Ruby 2.1
            object.add('no') unless object.values.include? 'no' # rubocop:disable Performance/InefficientHashSearch Not supported on Ruby 2.1
          end
          break
        end
      end
    end
  end

  def set_default_namevar(object)
    return unless object.properties || object.parameters
    default = nil
    if object.properties
      object.properties.each do |property|
        return nil if property.isnamevar
        default = property if property.name == 'name'
      end
    end
    if object.parameters
      object.parameters.each do |parameter|
        return nil if parameter.isnamevar
        default ||= parameter if parameter.name == 'name'
      end
    end
    default.isnamevar = true if default
  end
end
