require 'spec_helper'
require 'puppet-strings/json'
require 'tempfile'

describe PuppetStrings::Json do
  before :each do
    # Populate the YARD registry with both Puppet and Ruby source
    YARD::Parser::SourceParser.parse_string(<<-SOURCE, :puppet)
# A simple class.
# @todo Do a thing
# @note Some note
# @param param1 First param.
# @param param2 Second param.
# @param param3 Third param.
class klass(Integer $param1, $param2, String $param3 = hi) inherits foo::bar {
}

# A simple defined type.
# @param param1 First param.
# @param param2 Second param.
# @param param3 Third param.
define dt(Integer $param1, $param2, String $param3 = hi) {
}
    SOURCE

    YARD::Parser::SourceParser.parse_string(<<-SOURCE, :puppet) if TEST_PUPPET_PLANS
# A simple plan.
# @param param1 First param.
# @param param2 Second param.
# @param param3 Third param.
plan plann(String $param1, $param2, Integer $param3 = 1) {
}
    SOURCE

    # Only include Puppet functions for 4.1+
    YARD::Parser::SourceParser.parse_string(<<-SOURCE, :puppet) if TEST_PUPPET_FUNCTIONS
# A simple function.
# @param param1 First param.
# @param param2 Second param.
# @param param3 Third param.
# @return [Undef] Returns nothing.
function func(Integer $param1, $param2, String $param3 = hi) {
}
    SOURCE

    # Only include Puppet types for 5.0+
    YARD::Parser::SourceParser.parse_string(<<-SOURCE, :ruby) if TEST_PUPPET_DATATYPES
# Basic Puppet Data Type in Ruby
#
# @param msg A message parameter
Puppet::DataTypes.create_type('RubyDataType') do
  interface <<-PUPPET
    attributes => {
      msg => String[1]
    }
    PUPPET
end
SOURCE

    YARD::Parser::SourceParser.parse_string(<<-SOURCE, :json)
{
  "description": "Allows you to backup your database to local file.",
  "input_method": "stdin",
  "parameters": {
    "database": {
      "description": "Database to connect to",
      "type": "Optional[String[1]]"
    },
    "user": {
      "description": "The user",
      "type": "Optional[String[1]]"
    },
    "password": {
      "description": "The password",
      "type": "Optional[String[1]]"
    },
     "sql": {
      "description": "Path to file you want backup to",
      "type": "String[1]"
    }
  }
}
    SOURCE

    YARD::Parser::SourceParser.parse_string(<<-SOURCE, :ruby)
Puppet::Parser::Functions.newfunction(:func3x, doc: <<-DOC
An example 3.x function.
@param [String] first The first parameter.
@param second The second parameter.
@return [Undef] Returns nothing.
DOC
) do |*args|
end

# An example 4.x function.
Puppet::Functions.create_function(:func4x) do
  # The first overload.
  # @param param1 The first parameter.
  # @param param2 The second parameter.
  # @param param3 The third parameter.
  # @return Returns nothing.
  dispatch :foo do
    param          'Integer',       :param1
    param          'Any',           :param2
    optional_param 'Array[String]', :param3
    return_type 'Undef'
  end

  # @param param The first parameter.
  # @param block The block parameter.
  # @return Returns a string.
  dispatch :other do
    param 'Boolean', :param
    block_param
    return_type 'String'
  end
end

# An example 4.x function with only one signature.
Puppet::Functions.create_function(:func4x_1) do
  # @param param1 The first parameter.
  # @return [Undef] Returns nothing.
  dispatch :foobarbaz do
    param          'Integer',       :param1
  end
end

Puppet::Type.type(:database).provide :linux do
  desc 'An example provider on Linux.'
  confine kernel: 'Linux'
  confine osfamily: 'RedHat'
  defaultfor :kernel => 'Linux'
  defaultfor :osfamily => 'RedHat', :operatingsystemmajrelease => '7'
  has_feature :implements_some_feature
  has_feature :some_other_feature
  commands foo: '/usr/bin/foo'
end

Puppet::Type.newtype(:database) do
  desc 'An example database server resource type.'
  feature :encryption, 'The provider supports encryption.', methods: [:encrypt]
  ensurable do
    desc 'What state the database should be in.'
    defaultvalues
    aliasvalue(:up, :present)
    aliasvalue(:down, :absent)
    defaultto :up
  end

  newparam(:address) do
    isnamevar
    desc 'The database server name.'
  end

  newparam(:encryption_key, required_features: :encryption) do
    desc 'The encryption key to use.'
  end

  newparam(:encrypt, :parent => Puppet::Parameter::Boolean) do
    desc 'Whether or not to encrypt the database.'
    defaultto false
  end

  newproperty(:file) do
    desc 'The database file to use.'
  end

  newproperty(:log_level) do
    desc 'The log level to use.'
    newvalue(:debug)
    newvalue(:warn)
    newvalue(:error)
    defaultto 'warn'
  end
end

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
  attributes:   {
    ensure:      {
      type: 'Enum[present, absent]',
      desc: 'Whether this apt key should be present or absent on the target system.'
    },
    id:          {
      type:      'Variant[Pattern[/\A(0x)?[0-9a-fA-F]{8}\Z/], Pattern[/\A(0x)?[0-9a-fA-F]{16}\Z/], Pattern[/\A(0x)?[0-9a-fA-F]{40}\Z/]]',
      behaviour: :namevar,
      desc:      'The ID of the key you want to manage.',
    },
    # ...
    created:     {
      type:      'String',
      behaviour: :read_only,
      desc:      'Date the key was created, in ISO format.',
    },
  },
  autorequires: {
    file:    '$source', # will evaluate to the value of the `source` attribute
    package: 'apt',
  },
)
    SOURCE
  end

  RSpec.shared_examples "correct JSON" do
    it 'should include data for Puppet Classes' do
      puppet_class_json = YARD::Registry.all(:puppet_class).sort_by!(&:name).map!(&:to_hash).to_json

      expect(json_output).to include_json(puppet_class_json)
    end

    it 'should include data for Puppet Data Types' do
      data_types_json = YARD::Registry.all(:puppet_data_type).sort_by!(&:name).map!(&:to_hash).to_json
      expect(json_output).to include_json(data_types_json)
    end

    it 'should include data for Puppet Defined Types' do
      defined_types_json = YARD::Registry.all(:puppet_defined_type).sort_by!(&:name).map!(&:to_hash).to_json

      expect(json_output).to include_json(defined_types_json)
    end

    it 'should include data for Puppet Resouce Types' do
      resource_types_json = YARD::Registry.all(:puppet_type).sort_by!(&:name).map!(&:to_hash).to_json

      expect(json_output).to include_json(resource_types_json)
    end

    it 'should include data for Puppet Providers' do
      providers_json = YARD::Registry.all(:puppet_provider).sort_by!(&:name).map!(&:to_hash).to_json

      expect(json_output).to include_json(providers_json)
    end

    it 'should include data for Puppet Functions', if: TEST_PUPPET_FUNCTIONS do
      puppet_functions_json = YARD::Registry.all(:puppet_function).sort_by!(&:name).map!(&:to_hash).to_json

      expect(json_output).to include_json(puppet_functions_json)
    end

    it 'should include data for Puppet Tasks' do
      puppet_tasks_json = YARD::Registry.all(:puppet_task).sort_by!(&:name).map!(&:to_hash).to_json

      expect(json_output).to include_json(puppet_tasks_json)
    end

    it 'should include data for Puppet Plans', if: TEST_PUPPET_PLANS do
      puppet_plans_json = YARD::Registry.all(:puppet_plan).sort_by!(&:name).map!(&:to_hash).to_json

      expect(json_output).to include_json(puppet_plans_json)
    end
  end

  describe 'rendering JSON to a file' do
    let(:json_output) do
      json_output = nil

      Tempfile.open('json') do |file|
        PuppetStrings::Json.render(file.path)

        json_output = File.read(file.path)
      end

      json_output
    end

    include_examples "correct JSON"
  end

  describe 'rendering JSON to stdout' do
    let(:json_output) { @json_output }

    before(:each) do
      output = StringIO.new

      old_stdout = $stdout
      $stdout = output

      PuppetStrings::Json.render(nil)

      $stdout = old_stdout

      @json_output = output.string
    end

    include_examples "correct JSON"
  end
end
