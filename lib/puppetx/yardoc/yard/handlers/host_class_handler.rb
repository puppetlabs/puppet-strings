require_relative 'base'

module Puppetx::Yardoc::YARD::Handlers
  class HostClassHandler < Base
    handles HostClassDefinition

    process do
      register HostClassObject.new(:root, statement.pops_obj.name)
    end
  end
end
