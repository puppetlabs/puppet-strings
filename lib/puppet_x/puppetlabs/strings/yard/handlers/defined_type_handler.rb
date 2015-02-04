class PuppetX::PuppetLabs::Strings::YARD::Handlers::DefinedTypeHandler < PuppetX::PuppetLabs::Strings::YARD::Handlers:: Base
  handles ResourceTypeDefinition

  process do
    obj = DefinedTypeObject.new(:root, statement.pops_obj.name) do |o|
      o.parameters = statement.parameters.map do |a|
        param_tuple = [a[0].pops_obj.name]
        param_tuple << ( a[1].nil? ? nil : a[1].source )
      end
    end

    register obj
  end
end
