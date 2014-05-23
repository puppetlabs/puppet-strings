require 'puppetx/yardoc'

require 'puppet/pops'

require_relative 'yard_statement'

module Puppetx::Yardoc::Pops
  # Loosely based on the TreeDumper classes in Pops::Model. The responsibility of
  # this class is to walk a Pops::Model and output objects that can be consumed
  # by YARD handlers.
  #
  # @note Currently, this class only extracts node, host class and type
  #   definitions.
  class YARDTransformer
    def initialize
      @transform_visitor = Puppet::Pops::Visitor.new(self, 'transform')
    end

    def transform(o)
      @transform_visitor.visit(o)
    end

    private

    def transform_Factory(o)
      transform(o.current)
    end

    def transform_Program(o)
      o.definitions.map{|d| transform(d)}
    end

    # Extract comments from "Definition" objects. That is: nodes definitions,
    # type definitions and class definitions. Wrap them into YARDStatement
    # objects that provide an interface for YARD handlers.
    def transform_Definition(o)
      YARDStatement.new(o)
    end

  end
end
