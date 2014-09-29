require 'puppetx/puppetlabs/strings/yard/handlers/base'

class Puppetx::PuppetLabs::Strings::YARD::Handlers::HostClassHandler < Puppetx::PuppetLabs::Strings::YARD::Handlers::Base
  handles HostClassDefinition

  process do
    obj = HostClassObject.new(:root, statement.pops_obj.name) do |o|
      o.parameters = statement.parameters.map do |a|
        param_tuple = [a[0].pops_obj.name]
        param_tuple << ( a[1].nil? ? nil : a[1].source )
      end
    end

    statement.pops_obj.tap do |o|
      if o.parent_class
        obj.parent_class = P(:root, o.parent_class)
      end
    end

    register obj
  end
end
