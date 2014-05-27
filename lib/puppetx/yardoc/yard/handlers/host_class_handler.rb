require_relative 'base'

module Puppetx::Yardoc::YARD::Handlers
  class HostClassHandler < Base
    handles HostClassDefinition

    process do
      obj = HostClassObject.new(:root, statement.pops_obj.name)

      statement.pops_obj.tap do |o|
        if o.parent_class
          obj.parent_class = P(:root, o.parent_class)
        end
      end

      register obj
    end
  end
end
