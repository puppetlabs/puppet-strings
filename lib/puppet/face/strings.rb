require 'puppet/face'
require 'puppet_x/puppetlabs/strings/yard/tags/directives'

Puppet::Face.define(:strings, '0.0.1') do
  summary "Generate Puppet documentation with YARD."

  # Ensures that the user has the needed features to use puppet strings
  def check_required_features
    unless Puppet.features.yard?
      raise RuntimeError, "The 'yard' gem must be installed in order to use this face."
    end

    unless Puppet.features.rgen?
      raise RuntimeError, "The 'rgen' gem must be installed in order to use this face."
    end

    if RUBY_VERSION.match(/^1\.8/)
      raise RuntimeError, "This face requires Ruby 1.9 or greater."
    end
  end

  action(:yardoc) do
    default

    summary "Generate YARD documentation from files."
    arguments "[manifest_file.pp ...]"

    when_invoked do |*args|
      check_required_features
      require 'puppet_x/puppetlabs/strings/util'

      PuppetX::PuppetLabs::Strings::Util.generate(args)

      # Puppet prints the return value of the action. The return value of this
      # action is that of the yardoc_actions invocation, which is the boolean
      # "true". This clutters the statistics yard prints, so instead return the
      # empty string. Note an extra newline will also be printed.
      ""
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
      require 'puppet_x/puppetlabs/strings/util'

      PuppetX::PuppetLabs::Strings::Util.serve(args)
    end
  end
end
