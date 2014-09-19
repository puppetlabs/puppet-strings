require 'puppet/face'
require 'puppetx/puppetlabs/strings/actions'

include Puppetx::PuppetLabs::Strings::Actions

Puppet::Face.define(:strings, '0.0.1') do
  summary "Generate Puppet documentation with YARD."

  action(:yardoc) do
    default

    summary "Generate YARD documentation from files."
    arguments "[manifest_file.pp ...]"

    when_invoked do |*args|
      check_required_features
      require 'puppetx/puppetlabs/strings/yard/plugin'

      # The last element of the argument array should be the options hash.
      #
      # NOTE: The Puppet Face will throw 'unrecognized option' errors if any
      # YARD options are passed to it. The best way to approach this problem is
      # by using the `.yardopts` file. YARD will autoload any options placed in
      # that file.
      opts = args.pop

      # For now, assume the remaining positional args are a list of manifest
      # and ruby files to parse.
      yard_args = (args.empty? ? MODULE_SOURCEFILES : args)

      generate_documentation(*yard_args)
    end
  end

  # NOTE: Modeled after the `yard gems` command which builds doc indicies
  # (.yardoc directories) for Ruby Gems. Currently lacks the fine-grained
  # control over where these indicies are created and just dumps them in the
  # module roots.

  action(:server) do
    summary "Serve YARD documentation for modules."

    when_invoked do |*args|
      check_required_features
      require 'puppetx/puppetlabs/strings/yard/plugin'

      opts = args.pop

      module_names = args

      # FIXME: This is pretty inefficient as it forcibly re-generates the YARD
      # indicies each time the server is started. However, it ensures things are
      # generated properly.
      module_list = index_documentation_for_modules(module_names)

      module_tuples = generate_module_tuples(module_list)

      module_tuples.map! do |mod|
        [mod[:name], mod[:index_path]]
      end

      # The `-m` flag means a list of name/path pairs will follow. The name is
      # used as the module name and the path indicates which `.yardoc` index to
      # generate documentation from.
      yard_args = %w[-m -q] + module_tuples.flatten
      merge_puppet_args!(yard_args)

      serve_documentation(*yard_args)
    end
  end
end

