require 'puppet-strings/yard/handlers/helpers'
require 'puppet-strings/yard/handlers/ruby/type_base'
require 'puppet-strings/yard/code_objects'
require 'puppet-strings/yard/util'

# Implements the handler for Puppet resource type newparam/newproperty calls written in Ruby.
class PuppetStrings::Yard::Handlers::Ruby::TypeExtrasHandler < PuppetStrings::Yard::Handlers::Ruby::TypeBase
  # The default docstring when ensurable is used without given a docstring.
  DEFAULT_ENSURABLE_DOCSTRING = 'The basic property that the resource should be in.'.freeze

  namespace_only
  handles method_call(:newparam)
  handles method_call(:newproperty)

  process do

    # Our entry point is a type newproperty/newparam compound statement like this:
    #  "Puppet::Type.type(:file).newparam(:content) do"
    # We want to
    #  Verify the structure
    #  Capture the three parameters (e.g. type: 'file', newproperty or newparam?, name: 'source')
    #  Proceed with collecting data
    #  Either decorate an existing type object or store for future type object parsing

    # Only accept calls to Puppet::Type.type(<type>).newparam/.newproperty
    # e.g. "Puppet::Type.type(:file).newparam(:content) do" would yield:
    #   module_name:  "Puppet::Type"
    #   method1_name: "type"
    #   typename:     "file"
    #   method2_name: "newparam"
    #   propertyname: "content"

    return unless (statement.count > 1) && (statement[0].children.count > 2)
    module_name = statement[0].children[0].source
    method1_name = statement[0].children[1].source
    return unless (module_name == 'Puppet::Type' || module_name == 'Type') && method1_name == 'type'

    typename = get_name(statement[0], 'Puppet::Type.type')
    method2_name = caller_method
    propertyname = get_name(statement, "Puppet::Type.type().#{method2_name}")

    typeobject = get_type_yard_object(typename)

    # node - what should it be here?
    node = statement #?? not sure... test...

    if method2_name == 'newproperty'
      typeobject.add_property(create_property(propertyname, node))
    elsif method2_name == 'newparam'
      typeobject.add_parameter(create_parameter(propertyname, node))
    end

    # Set the default namevar
    set_default_namevar(typeobject)
  end
end
