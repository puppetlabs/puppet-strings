class HereDocHelper
  # NOTE: The following methods duplicate functionality from
  # Puppet::Util::Reference and Puppet::Parser::Functions.functiondocs
  #
  # However, implementing this natively in YARD is a good test for the
  # feasibility of extracting custom Ruby documentation. In the end, the
  # existing approach taken by Puppet::Util::Reference may be the best due to
  # the heavy use of metaprogramming in Types and Providers.

  # Extracts the Puppet function name and options hash from the parsed
  # definition.
  #
  # @return [(String, Hash{String => String})]
  def process_parameters(statement)
    # Passing `false` to prameters excludes the block param from the returned
    # list.
    name, opts = statement.parameters(false).compact

    name = process_element(name)

    # Don't try to process options if we don't have any
    if !opts.nil?
      opts = opts.map do |tuple|
        # Jump down into the S-Expression that represents a hashrocket, `=>`,
        # and the values on either side of it.
        tuple.jump(:assoc).map{|e| process_element(e)}
      end

      options = Hash[opts]
    else
      options = {}
    end

    [name, options]
  end

  # Sometimes the YARD parser returns Heredoc strings that start with `<-`
  # instead of `<<-`.
  HEREDOC_START = /^<?<-/

  def is_heredoc?(str)
    HEREDOC_START.match(str)
  end

    # Turns an entry in the method parameter list into a string.
    #
    # @param ele [YARD::Parser::Ruby::AstNode]
    # @return [String]
    def process_element(ele)
      ele = ele.jump(:ident, :symbol, :string_content)

      case ele.type
      when :ident
        ele.source
      when :symbol
        ele.source[1..-1]
      when :string_content
        source = ele.source
        if is_heredoc? source
          process_heredoc(source)
        else
          source
        end
      end
    end

  # Cleans up and formats Heredoc contents parsed by YARD.
  #
  # @param source [String]
  # @return [String]
  def process_heredoc(source)
    source = source.lines.to_a

    # YARD adds a line of source context on either side of the Heredoc
    # contents.
    source.shift
    source.pop

    # This utility method normalizes indentation and trims whitespace.
    Puppet::Util::Docs.scrub(source.join)
  end
end
