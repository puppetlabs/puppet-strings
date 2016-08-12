class PuppetX::PuppetLabs::Strings::YARD::Handlers::DefinedTypeHandler < PuppetX::PuppetLabs::Strings::YARD::Handlers:: Base
  handles ResourceTypeDefinition

  process do
    obj = DefinedTypeObject.new(:root, statement.pops_obj.name) do |o|
      o.parameters = statement.parameters.map do |a|
        param_tuple = [a[0].pops_obj.name]
        param_tuple << ( a[1].nil? ? nil : a[1].source )
      end
    end
    tp = Puppet::Pops::Types::TypeParser.new
    param_type_info = {}
    statement.pops_obj.parameters.each do |pop_param|
      # If the parameter's type expression is nil, default to Any
      if pop_param.type_expr == nil
        param_type_info[pop_param.name] = Puppet::Pops::Types::TypeFactory.any()
      else
        begin
          # This is a bit of a hack because we were using a method that was previously
          # API private. See PDOC-75 for more details
          if Puppet::Pops::Types::TypeParser.instance_method(:interpret_any).arity == 2
            param_type_info[pop_param.name] = tp.interpret_any(pop_param.type_expr, nil)
          else
            param_type_info[pop_param.name] = tp.interpret_any(pop_param.type_expr)
          end
        rescue Puppet::ParseError => e
          # If the type could not be interpreted insert a prominent warning
          param_type_info[pop_param.name] = "Type Error: #{e.message}"
        end
      end
    end
    obj.type_info = [param_type_info]


    register obj
  end
end
