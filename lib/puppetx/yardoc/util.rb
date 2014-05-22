require 'puppetx'
require 'puppet/pops'

# TODO: A catch-all module for now. Everything in here should eventually move
# to a designated home.
module Puppetx::Yardoc
  # Loosly based on the TreeDumper classes in Pops::Model.
  class Puppetx::Yardoc::Commentor
    def initialize
      @docstring_visitor = Puppet::Pops::Visitor.new(self,'docstring')
    end

    def get_comments(parse_result)
      @docstring_visitor.visit(parse_result)
    end

    private

    COMMENT_PATTERN = /^\s*#.*\n/

    def comments(o)
      @docstring_visitor.visit(o)
    end

    def docstring_Factory(o)
      comments(o.current)
    end

    def docstring_Program(o)
      @source_text = o.source_text.lines.to_a
      @locator = o.locator

      o.definitions.map{|d| comments(d)}
    end

    # Extract comments from "Definition" objects. That is: nodes definitions,
    # type definitions and class definitions.
    def docstring_Definition(o)
      line = @locator.line_for_offset(o.offset)
      comments_before(line)
    end

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
