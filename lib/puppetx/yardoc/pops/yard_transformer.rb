require 'puppetx/yardoc'

require 'puppet/pops'

module Puppetx::Yardoc::Pops
  # Loosely based on the TreeDumper classes in Pops::Model. The responsibility of
  # this class is to walk a Pops::Model and output objects that can be consumed
  # by YARD handlers.
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
      # FIXME: Uuuuuughhhhhhhhh.... This should be extracted some other way.
      # Perhaps using a SourcePosAdapter?
      @source_text = o.source_text.lines.to_a
      @locator = o.locator

      o.definitions.map{|d| transform(d)}
    end

    # Extract comments from "Definition" objects. That is: nodes definitions,
    # type definitions and class definitions.
    def transform_Definition(o)
      line = @locator.line_for_offset(o.offset)
      comments_before(line)
    end

    # TODO: This stuff should probably be part of a separate class/adapter.
    COMMENT_PATTERN = /^\s*#.*\n/

    def comments_before(line)
      comments = []

      # FIXME: Horribly inefficient. Multiple copies. Generator pattern would
      # be much better.
      @source_text.slice(0, line-1).reverse.each do |line|
        if COMMENT_PATTERN.match(line)
          comments.unshift line
        else
          # No comment found on this line. We must be done piecing together a
          # comment block.
          break
        end
      end

      # Stick everything back together.
      comments.join
    end
  end
end
