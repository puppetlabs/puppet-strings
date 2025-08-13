# frozen_string_literal: true

require 'yard'

# Module for YARD related functionality.
module OpenvoxStrings::Yard
  require 'openvox-strings/yard/code_objects'
  require 'openvox-strings/yard/handlers'
  require 'openvox-strings/yard/tags'
  require 'openvox-strings/yard/parsers'
  require 'openvox-strings/monkey_patches/display_object_command'

  # Sets up YARD for use with openvox-strings.
  # @return [void]
  def self.setup!
    # Register our factory
    YARD::Tags::Library.default_factory = OpenvoxStrings::Yard::Tags::Factory

    # Register the template path
    YARD::Templates::Engine.register_template_path(File.join(File.dirname(__FILE__), 'yard', 'templates'))

    # Register the Puppet parser
    YARD::Parser::SourceParser.register_parser_type(:puppet, OpenvoxStrings::Yard::Parsers::Puppet::Parser, ['pp'])
    YARD::Parser::SourceParser.register_parser_type(:json, OpenvoxStrings::Yard::Parsers::JSON::Parser, ['json'])

    # Register our handlers
    YARD::Handlers::Processor.register_handler_namespace(:puppet, OpenvoxStrings::Yard::Handlers::Puppet)
    YARD::Handlers::Processor.register_handler_namespace(:puppet_ruby, OpenvoxStrings::Yard::Handlers::Ruby)
    YARD::Handlers::Processor.register_handler_namespace(:json, OpenvoxStrings::Yard::Handlers::JSON)

    # Register the tag directives
    OpenvoxStrings::Yard::Tags::ParameterDirective.register!
    OpenvoxStrings::Yard::Tags::PropertyDirective.register!

    # Register the summary tag
    OpenvoxStrings::Yard::Tags::SummaryTag.register!

    # Register the enum tag
    OpenvoxStrings::Yard::Tags::EnumTag.register!

    # Ignore documentation on Puppet DSL calls
    # This prevents the YARD DSL parser from emitting warnings for Puppet's Ruby DSL
    YARD::Handlers::Ruby::DSLHandlerMethods::IGNORE_METHODS['create_function'] = true
    YARD::Handlers::Ruby::DSLHandlerMethods::IGNORE_METHODS['newtype'] = true
  end
end

# Monkey patch YARD::CLI::Yardoc#all_objects to return our custom code objects.
# @private
class YARD::CLI::Yardoc
  def all_objects
    YARD::Registry.all(
      :root,
      :module,
      :class,
      :puppet_class,
      :puppet_data_type,
      :puppet_data_type_alias,
      :puppet_defined_type,
      :puppet_type,
      :puppet_provider,
      :puppet_function,
      :puppet_task,
      :puppet_plan,
    )
  end
end

# Monkey patch the stats object to return statistics for our objects.
# This is the recommended way to add custom stats.
# @private
class YARD::CLI::Stats
  def stats_for_puppet_classes
    output 'Puppet Classes', *type_statistics_all(:puppet_class)
  end

  def stats_for_puppet_data_types
    output 'Puppet Data Types', *type_statistics_all(:puppet_data_type)
  end

  def stats_for_puppet_data_type_aliases
    output 'Puppet Data Type Aliases', *type_statistics_all(:puppet_data_type_alias)
  end

  def stats_for_puppet_defined_types
    output 'Puppet Defined Types', *type_statistics_all(:puppet_defined_type)
  end

  def stats_for_puppet_types
    output 'Puppet Types', *type_statistics_all(:puppet_type)
  end

  def stats_for_puppet_providers
    output 'Puppet Providers', *type_statistics_all(:puppet_provider)
  end

  def stats_for_puppet_functions
    output 'Puppet Functions', *type_statistics_all(:puppet_function)
  end

  def stats_for_puppet_tasks
    output 'Puppet Tasks', *type_statistics_all(:puppet_task)
  end

  def stats_for_puppet_plans
    return unless OpenvoxStrings.puppet_5?

    output 'Puppet Plans', *type_statistics_all(:puppet_plan)
  end

  def output(name, data, undoc = nil)
    # Monkey patch output to accommodate our larger header widths
    @total += data if data.is_a?(Integer) && undoc
    @undocumented += undoc if undoc.is_a?(Integer)
    data =
      if undoc
        "#{data} (#{undoc} undocumented)"
      else
        data.to_s
      end
    log.puts("#{name.ljust(25)} #{data}")
  end

  # This differs from the YARD implementation in that it considers
  # a docstring without text but with tags to be undocumented.
  def type_statistics_all(type)
    objs = all_objects.select { |m| m.type == type }
    undoc = objs.select { |m| m.docstring.all.empty? }
    @undoc_list |= undoc if @undoc_list
    [objs.size, undoc.size]
  end
end
