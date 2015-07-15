class PuppetX::PuppetLabs::Strings::YARD::Handlers::HostClassHandler < PuppetX::PuppetLabs::Strings::YARD::Handlers::Base
  handles HostClassDefinition

  process do
    obj = HostClassObject.new(:root, statement.pops_obj.name) do |o|
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
        rescue Puppet::ParseError
          # If the type could not be interpreted, default to type Any
          param_type_info[pop_param.name] = "TypeError - " +
            "#{pop_param.type_expr} isn't a valid type."
        end
      end
    end
    obj.type_info = [param_type_info]

    statement.pops_obj.tap do |o|
      if o.parent_class
        obj.parent_class = P(:root, o.parent_class)
      end
    end

    register obj
  end
end
