require 'rake'
require 'rake/tasklib'
require 'puppet_x/puppetlabs/strings/util'

module PuppetStrings
  module RakeTasks
    # A configurable rake task to generate documentation using puppet-strings.
    #
    # @attr [String] name the name of the rake task.
    # @attr [Array<String>] module_resourcefiles globs used to specify which files to document.
    #   Defaults to {PuppetX::PuppetLabs::Strings::Util::MODULE_SOURCEFILES}
    # @attr [Array<String>] excludes a list of paths or patterns of files and directories to ignore.
    # @attr [Array<String>, nil] paths list of paths to generate documentation for.
    #   If this value is nil, uses the default paths for puppet strings.
    # @attr [Hash] options a hash with options passed through to yardoc.
    class Generate < ::Rake::TaskLib
      attr_accessor :name
      attr_accessor :module_resourcefiles
      attr_accessor :paths
      attr_accessor :excludes
      attr_accessor :options

      # Creates a new instance of the Generate Rake task.
      # Defaults the name to 'strings:generate which overrides
      # the namespaced generates task. Also default other attributes to
      # mimic the current default behaviour.
      def initialize(*args, &task_block)
        @name = args.shift || 'strings:generate'
        @module_sourcefiles = PuppetX::PuppetLabs::Strings::Util::MODULE_SOURCEFILES
        @paths = nil
        @options = {emit_json: 'strings.json'}
        @excludes = []
        define(args, &task_block)
      end

      # Creates the actual rake task after calling the task_block.
      #
      # @param [Array<String>] args arguments passed to the rake task.
      # @param [Proc] task_block block to configure the task.
      # @yield [self, args] configure this rake task.
      def define(args, &task_block)
        Rake::Task[@name].clear if Rake::Task.task_defined?(@name)
        yield(*[self, args].slice(0, task_block.arity)) if task_block


        desc 'Generate Puppet documentation with YARD.' unless ::Rake.application.last_description
        task @name do
          execute_task(generate_task_args)
        end
      end

      private

      # Converts all attributes and options to an arguments array that can be passed
      # through to {PuppetX::PuppetLabs::Strings::Util #generate}.
      #
      # If paths is not nil, we expand them with the module_sourcefiles patterns.
      def generate_task_args
        @paths = [*@paths] unless @paths.nil?
        @module_sourcefiles = [*@module_sourcefiles]
        @excludes = [*@excludes]

        exclude_args = @excludes.map {|x| ["--exclude", x]}.flatten
        pattern_args = @paths.nil? ? [] : expand_paths(@paths, @module_sourcefiles)

        exclude_args + pattern_args + [@options]
      end

      # Combine each prefix_path with each pattern with '/**/' glue.
      #
      # @example
      #   expand_paths(['a','b'], ['*.rb','*.pp'])
      #   => ["a/**/*.rb", "a/**/*.pp", "b/**/*.rb", "b/**/*.pp"]
      #
      # @param [Array<String>] prefix_paths an array with paths
      # @param [Array<String>] patterns an array with patterns.
      def expand_paths(prefix_paths, patterns)
        prefix_paths.map {|path| patterns.map {|p| "#{path}/**/#{p}" } }.flatten
      end

      # call {PuppetX::PuppetLabs::Strings::Util #generate}
      # @param [Array<String, Hash>] args Arguments. Last element should be a Hash.
      def execute_task(args)
        PuppetX::PuppetLabs::Strings::Util.generate(args)
      end
    end
  end
end
