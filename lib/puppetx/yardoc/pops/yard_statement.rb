require 'puppet/pops'

require_relative '../../yardoc'

module Puppetx::Yardoc::Pops
  # An adapter class that conforms a Pops model instance + adapters to the
  # interface expected by YARD handlers.
  class YARDStatement
    attr_reader :pops_obj, :comments

    def initialize(pops_obj)
      unless pops_obj.is_a? Puppet::Pops::Model::PopsObject
        raise ArgumentError, "A YARDStatement can only be initialized from a PopsObject. Got a: #{pops_obj.class}"
      end

      @pops_obj = pops_obj
      @pos_adapter = Puppet::Pops::Adapters::SourcePosAdapter.adapt(@pops_obj)
      # FIXME: Perhaps this should be a seperate adapter?
      @comments = extract_comments
    end

    def type
      pops_obj.class
    end

    def line
      @line ||= @pos_adapter.line
    end

    def source
      @source ||= @pos_adapter.extract_text
    end

    # FIXME: I don't know quite what these are supposed to do, but they show up
    # quite often in the YARD handler code. Figure out whether they are
    # necessary.
    alias_method :show, :source
    def comments_hash_flag; nil end
    def comments_range; nil end

    private
    # TODO: This stuff should probably be part of a separate class/adapter.
    COMMENT_PATTERN = /^\s*#.*\n/

    def extract_comments
      comments = []
      program = pops_obj.eAllContainers.find {|c| c.is_a?(Puppet::Pops::Model::Program) }
      # FIXME: Horribly inefficient. Multiple copies. Generator pattern would
      # be much better.
      source_text = program.source_text.lines.to_a

      source_text.slice(0, line-1).reverse.each do |line|
        if COMMENT_PATTERN.match(line)
          # FIXME: The gsub trims comments, but is extremely optimistic: It
          # assumes only one space separates the comment body from the
          # comment character.
          comments.unshift line.gsub(/^\s*#\s/, '')
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
