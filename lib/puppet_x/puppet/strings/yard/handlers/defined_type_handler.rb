class PuppetX::Puppet::Strings::YARD::Handlers::DefinedTypeHandler < PuppetX::Puppet::Strings::YARD::Handlers:: Base
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
          param_type_info[pop_param.name] =  tp.interpret_any(pop_param.type_expr)
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
