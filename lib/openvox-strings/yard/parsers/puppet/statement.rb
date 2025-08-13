# frozen_string_literal: true

require 'puppet'
require 'puppet/pops'

module OpenvoxStrings::Yard::Parsers::Puppet
  # Represents the base Puppet language statement.
  class Statement
    # The pattern for parsing docstring comments.
    COMMENT_REGEX = /^\s*#+\s?/

    attr_reader :source, :file, :line, :docstring, :comments_range

    # Initializes the Puppet language statement.
    # @param object The Puppet parser model object for the statement.
    # @param [String] file The file name of the file containing the statement.
    def initialize(object, file)
      @file = file

      @source = OpenvoxStrings::Yard::Util.ast_to_text(object)
      @line = object.line
      @comments_range = nil
    end

    # Extracts the docstring for the statement given the source lines.
    # @param [Array<String>] lines The source lines for the file containing the statement.
    # @return [void]
    def extract_docstring(lines)
      comment = []
      (0..@line - 2).reverse_each do |index|
        break unless index <= lines.count

        line = lines[index].strip
        count = line.size
        line.gsub!(COMMENT_REGEX, '')
        # Break out if nothing was removed (wasn't a comment line)
        break unless line.size < count

        comment << line
      end
      @comments_range = (@line - comment.size - 1..@line - 1)
      @docstring = YARD::Docstring.new(comment.reverse.join("\n"))
    end

    # Shows the first line context for the statement.
    # @return [String] Returns the first line context for the statement.
    def show
      "\t#{@line}: #{first_line}"
    end

    # Gets the full comments of the statement.
    # @return [String] Returns the full comments of the statement.
    def comments
      @docstring.all
    end

    # Determines if the comments have hash flag.
    # @return [Boolean] Returns true if the comments have a hash flag or false if not.
    def comments_hash_flag
      false
    end

    private

    def first_line
      @source.split(/\r?\n/).first.strip
    end
  end

  # Implements a parameterized statement (a statement that takes parameters).
  class ParameterizedStatement < Statement
    # Implements a parameter for a parameterized statement.
    class Parameter
      attr_reader :name, :type, :value

      # Initializes the parameter.
      # @param [Puppet::Pops::Model::Parameter] parameter The parameter model object.
      def initialize(parameter)
        @name = parameter.name
        # Take the exact text for the type expression
        @type = OpenvoxStrings::Yard::Util.ast_to_text(parameter.type_expr) if parameter.type_expr
        # Take the exact text for the default value expression
        return unless parameter.value

        @value = OpenvoxStrings::Yard::Util.ast_to_text(parameter.value)
      end
    end

    attr_reader :parameters

    # Initializes the parameterized statement.
    # @param object The Puppet parser model object that has parameters.
    # @param [String] file The file containing the statement.
    def initialize(object, file)
      super
      @parameters = object.parameters.map { |parameter| Parameter.new(parameter) }
    end
  end

  # Implements the Puppet class statement.
  class ClassStatement < ParameterizedStatement
    attr_reader :name, :parent_class

    # Initializes the Puppet class statement.
    # @param [Puppet::Pops::Model::HostClassDefinition] object The model object for the class statement.
    # @param [String] file The file containing the statement.
    def initialize(object, file)
      super
      @name = object.name
      @parent_class = object.parent_class
    end
  end

  # Implements the Puppet defined type statement.
  class DefinedTypeStatement < ParameterizedStatement
    attr_reader :name

    # Initializes the Puppet defined type statement.
    # @param [Puppet::Pops::Model::ResourceTypeDefinition] object The model object for the defined type statement.
    # @param [String] file The file containing the statement.
    def initialize(object, file)
      super
      @name = object.name
    end
  end

  # Implements the Puppet function statement.
  class FunctionStatement < ParameterizedStatement
    attr_reader :name, :type

    # Initializes the Puppet function statement.
    # @param [Puppet::Pops::Model::FunctionDefinition] object The model object for the function statement.
    # @param [String] file The file containing the statement.
    def initialize(object, file)
      super
      @name = object.name
      return unless object.respond_to? :return_type

      type = object.return_type
      return unless type

      @type = OpenvoxStrings::Yard::Util.ast_to_text(type).gsub('>> ', '')
    end
  end

  # Implements the Puppet plan statement.
  class PlanStatement < ParameterizedStatement
    attr_reader :name

    # Initializes the Puppet plan statement.
    # @param [Puppet::Pops::Model::PlanDefinition] object The model object for the plan statement.
    # @param [String] file The file containing the statement.
    def initialize(object, file)
      super
      @name = object.name
    end
  end

  # Implements the Puppet data type alias statement.
  class DataTypeAliasStatement < Statement
    attr_reader :name, :alias_of

    # Initializes the Puppet data type alias statement.
    # @param [Puppet::Pops::Model::TypeAlias] object The model object for the type statement.
    # @param [String] file The file containing the statement.
    def initialize(object, file)
      super

      type_expr = object.type_expr
      case type_expr
      when Puppet::Pops::Model::AccessExpression
        # TODO: I don't like rebuilding the source from the AST, but AccessExpressions don't expose the original source
        @alias_of = "#{OpenvoxStrings::Yard::Util.ast_to_text(type_expr.left_expr)}[" # alias_of should be mutable so we add a + to the string.
        @alias_of << type_expr.keys.map { |key| OpenvoxStrings::Yard::Util.ast_to_text(key) }.join(', ')
        @alias_of << ']'
      else
        @alias_of = OpenvoxStrings::Yard::Util.ast_to_text(type_expr)
      end
      @name = object.name
    end
  end
end
