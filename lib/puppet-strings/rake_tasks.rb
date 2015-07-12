require 'rake'
require 'rake/tasklib'
require 'puppet/face'
require 'puppet_x/puppetlabs/strings/actions'

MODULE_SOURCEFILES = ['manifests/**/*.pp', 'lib/**/*.rb']

def generate(args = [])
  yardoc_actions = PuppetX::PuppetLabs::Strings::Actions.new(Puppet[:debug], Puppet[:trace])

  # For now, assume the remaining positional args are a list of manifest
  # and ruby files to parse.
  yard_args = (args.empty? ? MODULE_SOURCEFILES : args)

  # This line monkeypatches yard's progress indicator so it doesn't write
  # all over the terminal. This should definitely not be in real code, but
  # it's very handy for debugging with pry
  #class YARD::Logger; def progress(*args); end; end

  yardoc_actions.generate_documentation(*yard_args)
end

def serve(args = [])
  server_actions = PuppetX::PuppetLabs::Strings::Actions.new(Puppet[:debug], Puppet[:trace])

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

namespace :strings do
  desc 'Generate Puppet documentation with YARD.'
  task :generate do
    generate
  end

  desc 'Serve YARD documentation for modules.'
  task :serve do
    serve
  end
end
