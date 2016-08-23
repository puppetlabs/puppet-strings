require 'puppet_x/puppet/strings/actions'

module PuppetX::Puppet::Strings::Util
  MODULE_SOURCEFILES = ['manifests/**/*.pp', 'lib/**/*.rb']

  def self.generate(args = [])
    yardoc_actions = PuppetX::Puppet::Strings::Actions.new(Puppet[:debug], Puppet[:trace])

    # The last element of the argument array should be the options hash.
    # We don't have any options yet, so for now just pop the hash off and
    # toss it.
    #
    # NOTE: The Puppet Face will throw 'unrecognized option' errors if any
    # YARD options are passed to it. The best way to approach this problem is
    # by using the `.yardopts` file. YARD will autoload any options placed in
    # that file.
    options = args.pop
    YARD::Config.options = YARD::Config.options.merge(options) if options

    # For now, assume the remaining positional args are a list of manifest
    # and ruby files to parse.
    yard_args = (args.empty? ? MODULE_SOURCEFILES : args)

    # If json is going to be emitted to stdout, suppress statistics.
    if options && options[:emit_json_stdout]
      yard_args.push('--no-stats')
    end

    # This line monkeypatches yard's progress indicator so it doesn't write
    # all over the terminal. This should definitely not be in real code, but
    # it's very handy for debugging with pry
    #class YARD::Logger; def progress(*args); end; end
    YARD::Tags::Library.define_directive("puppet.type.param",
      :with_types_and_name,
      PuppetX::Puppet::Strings::YARD::Tags::PuppetTypeParameterDirective)

    yardoc_actions.generate_documentation(*yard_args)
  end

  def self.serve(args = [])
    server_actions = PuppetX::Puppet::Strings::Actions.new(Puppet[:debug], Puppet[:trace])

    args.pop

    module_names = args

    # FIXME: This is pretty inefficient as it forcibly re-generates the YARD
    # indicies each time the server is started. However, it ensures things are
    # generated properly.
    module_list = server_actions.index_documentation_for_modules(module_names, MODULE_SOURCEFILES)

    module_tuples = server_actions.generate_module_tuples(module_list)

    module_tuples.map! do |mod|
      [mod[:name], mod[:index_path]]
    end

    # The `-m` flag means a list of name/path pairs will follow. The name is
    # used as the module name and the path indicates which `.yardoc` index to
    # generate documentation from.
    yard_args = %w[-m -q] + module_tuples.flatten

    server_actions.serve_documentation(*yard_args)
  end
end
