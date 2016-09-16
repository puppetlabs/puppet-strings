require 'spec_helper'
require 'puppet-strings/json'
require 'tempfile'

describe PuppetStrings::Json do
  before :each do
    # Populate the YARD registry with both Puppet and Ruby source
    YARD::Parser::SourceParser.parse_string(<<-SOURCE, :puppet)
# A simple class.
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
  # @return [Undef] Returns nothing.
  dispatch :foo do
    param          'Integer',       :param1
    param          'Any',           :param2
    optional_param 'Array[String]', :param3
  end

  # The second overload.
  # @param param The first parameter.
  # @param block The block parameter.
  # @return [String] Returns a string.
  dispatch :other do
    param 'Boolean', :param
    block_param
  end
end

Puppet::Type.type(:database).provide :linux do
  desc 'An example provider on Linux.'
  confine kernel: 'Linux'
  confine osfamily: 'RedHat'
  defaultfor kernel: 'Linux'
  has_feature :implements_some_feature
  has_feature :some_other_feature
  commands foo: /usr/bin/foo
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
SOURCE
  end

  let(:filename) { TEST_PUPPET_FUNCTIONS ? 'output.json' : 'output_without_puppet_function.json' }
  let(:baseline_path) { File.join(File.dirname(__FILE__), "../../fixtures/unit/json/#{filename}") }
  let(:baseline) { File.read(baseline_path) }

  describe 'rendering JSON to a file' do
    it 'should output the expected JSON content' do
      Tempfile.open('json') do |file|
        PuppetStrings::Json.render(file.path)
        expect(File.read(file.path)).to eq(baseline)
      end
    end
  end

  describe 'rendering JSON to stdout' do
    it 'should output the expected JSON content' do
      expect{ PuppetStrings::Json.render(nil) }.to output(baseline).to_stdout
    end
  end
end
