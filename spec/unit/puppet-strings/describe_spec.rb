require 'spec_helper'
require 'puppet-strings/describe'
require 'tempfile'

#TODO:
#basic describe
#params from other files (e.g. file content)
#--providers - list providers in detail
#X--list - list all providers summary
#--meta - List all metaparameters
#--short - only list params

describe PuppetStrings::Describe do
  before :each do
    # Populate the YARD registry with both Puppet and Ruby source


    YARD::Parser::SourceParser.parse_string(<<-SOURCE, :ruby)
Puppet::Type.newtype(:database) do
  desc 'An example database server resource type.'
end
    SOURCE

    YARD::Parser::SourceParser.parse_string(<<-SOURCE, :ruby)
Puppet::ResourceApi.register_type(
  name: 'apt_key',
  docs: <<-EOS,
@summary Example resource type using the new API.
@raise SomeError
This type provides Puppet with the capabilities to manage GPG keys needed
by apt to perform package validation. Apt has it's own GPG keyring that can
be manipulated through the `apt-key` command.
@example here's an example
  apt_key { '6F6B15509CF8E59E6E469F327F438280EF8D349F':
    source => 'http://apt.puppetlabs.com/pubkey.gpg'
  }

**Autorequires**:
If Puppet is given the location of a key file which looks like an absolute
path this type will autorequire that file.
  EOS
)
    SOURCE

    YARD::Parser::SourceParser.parse_string(<<-SOURCE, :ruby)
  Puppet::Type.type(:file).newproperty(:content) do
    include Puppet::Util::Checksums
    include Puppet::DataSync

    attr_reader :actual_content

    desc <<-'EOT'
      The desired contents of a file, as a string. This attribute is mutually
      exclusive with `source` and `target`.
    EOT
  end
    SOURCE

    YARD::Parser::SourceParser.parse_string(<<-SOURCE, :ruby)
  Puppet::Type.newtype(:file) do
    include Puppet::Util::Checksums
    include Puppet::Util::Backups
    include Puppet::Util::SymbolicFileMode

    @doc = "Manages files, including their content, ownership, and permissions.

      The `file` type can manage normal files, directories, and symlinks; the
      type should be specified in the `ensure` attribute."

    newparam(:path) do
      desc <<-'EOT'
        The path to the file to manage.  Must be fully qualified.

        On Windows, the path should include the drive letter and should use `/` as
        the separator character (rather than `\\`).
      EOT
      isnamevar
    end

  end
    SOURCE

    YARD::Parser::SourceParser.parse_string(<<-SOURCE, :ruby)
Puppet::Type.type(:file).newproperty(:source) do
  include Puppet::Util::Checksums
  include Puppet::DataSync

  attr_reader :actual_content

  desc <<-'EOT'
    The desired contents of a file, as a string. This attribute is mutually
    exclusive with `source` and `target`.
  EOT
end
    SOURCE
  end

  describe 'rendering DESCRIBE to stdout' do
    it 'should output the expected describe content for the list of types' do
      output = <<-DATA
These are the types known to puppet:
apt_key         - This type provides Puppet with the capabiliti ...
database        - An example database server resource type.
file            - Manages files, including their content, owner ...
      DATA
      expect{ PuppetStrings::Describe.render(nil, true) }.to output(output).to_stdout
    end
    it 'should output the expected describe content for a type' do
      output = <<-DATA

file
====
Manages files, including their content, ownership, and permissions.

The `file` type can manage normal files, directories, and symlinks; the
type should be specified in the `ensure` attribute.

Parameters
----------

- **content**
The desired contents of a file, as a string. This attribute is mutually
exclusive with `source` and `target`.

- **path**
The path to the file to manage.  Must be fully qualified.

On Windows, the path should include the drive letter and should use `/` as
the separator character (rather than `\\`).

- **source**
The desired contents of a file, as a string. This attribute is mutually
exclusive with `source` and `target`.

Providers
---------
      DATA
      expect{ PuppetStrings::Describe.render(['file']) }.to output(output).to_stdout
    end
  end
end
