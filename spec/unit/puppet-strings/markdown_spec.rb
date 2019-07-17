require 'spec_helper'
require 'puppet-strings/markdown'
require 'puppet-strings/markdown/table_of_contents'
require 'tempfile'

describe PuppetStrings::Markdown do
  def parse_shared_content
    # Populate the YARD registry with both Puppet and Ruby source
    YARD::Parser::SourceParser.parse_string(<<-SOURCE, :puppet)
# An overview for a simple class.
# @summary A simple class.
# @todo Do a thing
# @note some note
# @since 1.0.0
# @see www.puppet.com
# @example This is an example
#  class { 'klass':
#    param1 => 1,
#    param3 => 'foo',
#  }
# @example This is another example
#  class { 'klass':
#    param1 => 1,
#    param3 => 'foo',
#  }
# @raise SomeError
# @param param1 First param.
# @param param2 Second param.
# @option param2 [String] :opt1 something about opt1
# @option param2 [Hash] :opt2 a hash of stuff
# @param param3 Third param.
#
class klass (
  Integer $param1 = 1,
  $param2 = undef,
  String $param3 = 'hi'
) inherits foo::bar {
}

# Overview for class noparams
# @api private
class noparams () {}

# An overview for a simple defined type.
# @summary A simple defined type.
# @since 1.1.0
# @see www.puppet.com
# @example Here's an example of this type:
#  klass::dt { 'foo':
#    param1 => 33,
#    param4 => false,
#  }
# @return shouldn't return squat
# @raise SomeError
# @param param1 First param.
# @param param2 Second param.
# @option param2 [String] :opt1 something about opt1
# @option param2 [Hash] :opt2 a hash of stuff
# @param param3 Third param.
# @param param4 Fourth param.
define klass::dt (
  Integer $param1 = 44,
  $param2,
  String $param3 = 'hi',
  Boolean $param4 = true
) {
}
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

    YARD::Parser::SourceParser.parse_string(<<-SOURCE, :puppet)
# A simple Puppet function.
# @param param1 First param.
# @param param2 Second param.
# @param param3 Third param.
# @option param3 [Array] :param3opt Something about this option
# @raise SomeError this is some error
# @return [Undef] Returns nothing.
# @example Test
#   $result = func(1, 2)
function func(Integer $param1, $param2, String $param3 = hi) {
}
    SOURCE

    YARD::Parser::SourceParser.parse_string(<<-SOURCE, :ruby)
# An example 4.x function.
#
# @example Calling the function
#   $result = func4x(1, 'foo')
#
# @example Calling the function with all args
#   $result = func4x(1, 'foo', ['bar'])
Puppet::Functions.create_function(:func4x) do
  # An overview for the first overload.
  # @raise SomeError this is some error
  # @param param1 The first parameter.
  # @param param2 The second parameter.
  # @option param2 [String] :option an option
  # @option param2 [String] :option2 another option
  # @param param3 The third parameter.
  # @return Returns nothing.
  # @example Calling the function foo
  #   $result = func4x(1, 'foooo')
  #
  dispatch :foo do
    param          'Integer',       :param1
    param          'Any',           :param2
    optional_param 'Array[String]', :param3
    return_type 'Undef'
  end

  # An overview for the second overload.
  # @param param The first parameter.
  # @param block The block parameter.
  # @return Returns a string.
  # @example Calling the function bar
  #   $result = func4x(1, 'bar', ['foo'])
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

# An example 3.x function
Puppet::Parser::Functions.newfunction(:func3x, doc: <<-DOC
 Documentation for an example 3.x function.
 @param param1 [String] The first parameter.
 @param param2 [Integer] The second parameter.
 @return [Undef]
 @example Calling the function.
   func3x('hi', 10)
 DOC
 ) do |*args|
   #...
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
  desc <<-DESC
An example database server type.
@option opts :foo bar
@raise SomeError
@example here's an example
 database { 'foo':
   address => 'qux.baz.bar',
 }
DESC
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

  def parse_plan_content
    YARD::Parser::SourceParser.parse_string(<<-SOURCE, :puppet)
# A simple plan.
# @param param1 First param.
# @param param2 Second param.
# @param param3 Third param.
plan plann(String $param1, $param2, Integer $param3 = 1) {
}
    SOURCE
  end

  def parse_data_type_content
    YARD::Parser::SourceParser.parse_string(<<-SOURCE, :ruby)
# An example Puppet Data Type in Ruby.
#
# @param param1 A variant parameter.
# @param param2 Optional String parameter.
Puppet::DataTypes.create_type('UnitDataType') do
  interface <<-PUPPET
    attributes => {
      param1 => Variant[Numeric, String[1,2]],
      param2 => { type => Optional[String[1]], value => "param2" }
    }
    PUPPET
end
    SOURCE

    YARD::Parser::SourceParser.parse_string(<<-SOURCE, :puppet)
# Documentation for Amodule::SimpleAlias
type Amodule::SimpleAlias = Variant[Numeric,String[1,20]]

# Documentation for Amodule::ComplexAlias
type Amodule::ComplexAlias = Struct[{
  value_type => Optional[ValueType],
  merge      => Optional[MergeType]
}]
    SOURCE
  end
  let(:baseline_path) { File.join(File.dirname(__FILE__), "../../fixtures/unit/markdown/#{filename}") }
  let(:baseline) { File.read(baseline_path) }

  describe 'rendering markdown to a file' do
    before(:each) do
      parse_shared_content
    end

    context 'with common Puppet and ruby content' do
      let(:filename) { 'output.md' }

      it 'should output the expected markdown content' do
        Tempfile.open('md') do |file|
          PuppetStrings::Markdown.render(file.path)
          expect(File.read(file.path)).to eq(baseline)
        end
      end
    end

    describe 'with Puppet Plans', :if => TEST_PUPPET_PLANS do
      let(:filename) { 'output_with_plan.md' }

      before(:each) do
        parse_plan_content
      end

      it 'should output the expected markdown content' do
        Tempfile.open('md') do |file|
          PuppetStrings::Markdown.render(file.path)
          expect(File.read(file.path)).to eq(baseline)
        end
      end
    end

    describe 'with Puppet Data Types', :if => TEST_PUPPET_DATATYPES do
      let(:filename) { 'output_with_data_types.md' }

      before(:each) do
        parse_data_type_content
      end

      it 'should output the expected markdown content' do
        Tempfile.open('md') do |file|
          PuppetStrings::Markdown.render(file.path)
          expect(File.read(file.path)).to eq(baseline)
        end
      end
    end
  end
end
