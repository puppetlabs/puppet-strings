require 'spec_helper'
require 'puppet-strings/yard'

describe PuppetStrings::Yard::Handlers::Ruby::DataTypeHandler, if: TEST_PUPPET_DATATYPES do
  subject {
    YARD::Parser::SourceParser.parse_string(source, :ruby)
    YARD::Registry.all(:puppet_data_type)
  }

  before(:each) do
    # Tests may suppress logging to make it easier to read results,
    # so remember the logging object prior to running the test
    @original_yard_logging_object = YARD::Logger.instance.io
  end

  after(:each) do
    # Restore the original logging IO object
    YARD::Logger.instance.io = @original_yard_logging_object
  end

  def suppress_yard_logging
    YARD::Logger.instance.io = nil
  end

  describe 'parsing source without a data type definition' do
    let(:source) { 'puts "hi"' }

    it 'no data types should be in the registry' do
      expect(subject.empty?).to eq(true)
    end
  end

  describe 'parsing an empty data type definition' do
    let(:source) { <<-SOURCE
Puppet::DataTypes.create_type('RubyDataType') do
end
SOURCE
    }

    it 'should register a data type object with no param tags' do
      expect(subject.size).to eq(1)
      object = subject.first
      expect(object).to be_a(PuppetStrings::Yard::CodeObjects::DataType)
      expect(object.namespace).to eq(PuppetStrings::Yard::CodeObjects::DataTypes.instance)
      expect(object.name).to eq(:RubyDataType)
      expect(object.docstring).to eq('')
      expect(object.docstring.tags.size).to eq(1)
      tags = object.docstring.tags(:api)
      expect(tags.size).to eq(1)
      expect(tags[0].text).to eq('public')

      expect(object.parameters.size).to eq(0)
    end
  end

  describe 'parsing a data type definition with missing param tags' do
    let(:source) { <<-SOURCE
# An example Puppet Data Type in Ruby.
Puppet::DataTypes.create_type('RubyDataType') do
  interface <<-PUPPET
    attributes => {
      msg => String[1],
    }
    PUPPET
end
SOURCE
    }

    it 'should output a warning' do
      expect{ subject }.to output(/\[warn\]: Missing @param tag for attribute 'msg' near \(stdin\):2/).to_stdout_from_any_process
    end

    it 'should register a data type object with all param tags' do
      suppress_yard_logging

      expect(subject.size).to eq(1)
      object = subject.first
      expect(object).to be_a(PuppetStrings::Yard::CodeObjects::DataType)
      expect(object.namespace).to eq(PuppetStrings::Yard::CodeObjects::DataTypes.instance)
      expect(object.name).to eq(:RubyDataType)
      expect(object.docstring).to eq('An example Puppet Data Type in Ruby.')
      expect(object.docstring.tags.size).to eq(2)
      tags = object.docstring.tags(:api)
      expect(tags.size).to eq(1)
      expect(tags[0].text).to eq('public')

      # Check that the param tags are created
      tags = object.docstring.tags(:param)
      expect(tags.size).to eq(1)
      expect(tags[0].name).to eq('msg')
      expect(tags[0].text).to eq('')
      expect(tags[0].types).to eq(['String[1]'])

      # Check for default values for parameters
      expect(object.parameters.size).to eq(1)
      expect(object.parameters[0]).to eq(['msg', nil])
    end
  end

  describe 'parsing a data type definition with extra param tags' do
    let(:source) { <<-SOURCE
# An example Puppet Data Type in Ruby.
# @param msg A message parameter.
# @param arg1 Optional String parameter. Defaults to 'param'.
Puppet::DataTypes.create_type('RubyDataType') do
  interface <<-PUPPET
    attributes => {
      msg => Numeric,
    }
    PUPPET
end
SOURCE
    }

    it 'should output a warning' do
      expect{ subject }.to output(/\[warn\]: The @param tag for 'arg1' has no matching attribute near \(stdin\):4/).to_stdout_from_any_process
    end

    it 'should register a data type object with extra param tags removed' do
      suppress_yard_logging

      expect(subject.size).to eq(1)
      object = subject.first
      expect(object).to be_a(PuppetStrings::Yard::CodeObjects::DataType)
      expect(object.namespace).to eq(PuppetStrings::Yard::CodeObjects::DataTypes.instance)
      expect(object.name).to eq(:RubyDataType)
      expect(object.docstring).to eq('An example Puppet Data Type in Ruby.')
      expect(object.docstring.tags.size).to eq(2)
      tags = object.docstring.tags(:api)
      expect(tags.size).to eq(1)
      expect(tags[0].text).to eq('public')

      # Check that the param tags are removed
      tags = object.docstring.tags(:param)
      expect(tags.size).to eq(1)
      expect(tags[0].name).to eq('msg')
      expect(tags[0].text).to eq('A message parameter.')
      expect(tags[0].types).to eq(['Numeric'])

      # Check that only the actual attributes appear
      expect(object.parameters.size).to eq(1)
      expect(object.parameters[0]).to eq(['msg', nil])
    end
  end

  describe 'parsing a valid data type definition' do
    let(:source) { <<-SOURCE
# An example Puppet Data Type in Ruby.
#
# @param msg A message parameter5.
# @param arg1 Optional String parameter5. Defaults to 'param'.
Puppet::DataTypes.create_type('RubyDataType') do
  interface <<-PUPPET
    attributes => {
      msg   => Variant[Numeric, String[1,2]],
      arg1  => { type => Optional[String[1]], value => "param" }
    }
    PUPPET
end
SOURCE
    }

    it 'should register a data type object' do
      expect(subject.size).to eq(1)
      object = subject.first
      expect(object).to be_a(PuppetStrings::Yard::CodeObjects::DataType)
      expect(object.namespace).to eq(PuppetStrings::Yard::CodeObjects::DataTypes.instance)
      expect(object.name).to eq(:RubyDataType)
      expect(object.docstring).to eq('An example Puppet Data Type in Ruby.')
      expect(object.docstring.tags.size).to eq(3)
      tags = object.docstring.tags(:api)
      expect(tags.size).to eq(1)
      expect(tags[0].text).to eq('public')

      # Check that the param tags are removed
      tags = object.docstring.tags(:param)
      expect(tags.size).to eq(2)
      expect(tags[0].name).to eq('msg')
      expect(tags[0].text).to eq('A message parameter5.')
      expect(tags[0].types).to eq(['Variant[Numeric, String[1,2]]'])
      expect(tags[1].name).to eq('arg1')
      expect(tags[1].text).to eq('Optional String parameter5. Defaults to \'param\'.')
      expect(tags[1].types).to eq(['Optional[String[1]]'])

      # Check for default values
      expect(object.parameters.size).to eq(2)
      expect(object.parameters[0]).to eq(['msg', nil])
      expect(object.parameters[1]).to eq(['arg1', 'param'])
    end
  end

  testcases = [
    { :value => '-1', :expected => -1 },
    { :value => '0', :expected => 0 },
    { :value => '10', :expected => 10 },
    { :value => '0777', :expected => 511 },
    { :value => '0xFF', :expected => 255 },
    { :value => '0.1', :expected => 0.1 },
    { :value => '31.415e-1', :expected => 3.1415 },
    { :value => '0.31415e1', :expected => 3.1415 }
  ].each do |testcase|
    describe "parsing a valid data type definition with numeric default #{testcase[:value]}" do
      let(:source) { <<-SOURCE
# An example Puppet Data Type in Ruby.
# @param num1 A numeric parameter
Puppet::DataTypes.create_type('RubyDataType') do
  interface <<-PUPPET
    attributes => {
      num1 => { type => Numeric, value => #{testcase[:value]} },
    }
    PUPPET
end
SOURCE
      }

      it 'should register a data type object' do
        expect(subject.size).to eq(1)
        object = subject.first
        expect(object).to be_a(PuppetStrings::Yard::CodeObjects::DataType)
        expect(object.parameters.size).to eq(1)
        expect(object.parameters[0]).to eq(['num1', testcase[:expected]])
      end
    end
  end

  describe 'parsing a invalid data type definition' do
    let(:source) { <<-SOURCE
# The msg attribute is missing a comma.
#
# @param msg A message parameter5.
# @param arg1 Optional String parameter5. Defaults to 'param'.
Puppet::DataTypes.create_type('RubyDataType') do
  interface <<-PUPPET
    attributes => {
      msg   => Variant[Numeric, String[1,2]]
      arg1  => { type => Optional[String[1]], value => "param" }
    }
    PUPPET
end
SOURCE
    }

    it 'should register a partial data type object' do
      expect(subject.size).to eq(1)
      object = subject.first
      expect(object).to be_a(PuppetStrings::Yard::CodeObjects::DataType)
      expect(object.namespace).to eq(PuppetStrings::Yard::CodeObjects::DataTypes.instance)
      expect(object.name).to eq(:RubyDataType)
      expect(object.docstring).to eq('The msg attribute is missing a comma.')
      # The attributes will be missing therefore only one tag
      expect(object.docstring.tags.size).to eq(1)
      tags = object.docstring.tags(:api)
      expect(tags.size).to eq(1)
      expect(tags[0].text).to eq('public')

      # Check that the param tags are removed
      tags = object.docstring.tags(:param)
      expect(tags.size).to eq(0)

      # Check for default values
      expect(object.parameters.size).to eq(0)
    end

    it 'should log a warning' do
      expect{ subject }.to output(/\[warn\]: Invalid datatype definition at (.+):[0-9]+: Syntax error at 'arg1'/).to_stdout_from_any_process
    end
  end

  describe 'parsing a data type with a summary' do
    context 'when the summary has fewer than 140 characters' do
      let(:source) { <<-SOURCE
# An example Puppet Data Type in Ruby.
#
# @summary A short summary.
Puppet::DataTypes.create_type('RubyDataType') do
  interface <<-PUPPET
    attributes => { }
    PUPPET
end
SOURCE
      }

      it 'should parse the summary' do
        expect{ subject }.to output('').to_stdout_from_any_process
        expect(subject.size).to eq(1)
        summary = subject.first.tags(:summary)
        expect(summary.first.text).to eq('A short summary.')
      end
    end

    context 'when the summary has more than 140 characters' do
      let(:source) { <<-SOURCE
# An example Puppet Data Type in Ruby.
#
# @summary A short summary that is WAY TOO LONG. AHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH this is not what a summary is for! It should be fewer than 140 characters!!
Puppet::DataTypes.create_type('RubyDataType') do
  interface <<-PUPPET
    attributes => { }
    PUPPET
end
SOURCE
      }

      it 'should log a warning' do
        expect{ subject }.to output(/\[warn\]: The length of the summary for puppet_data_type 'RubyDataType' exceeds the recommended limit of 140 characters./).to_stdout_from_any_process
      end
    end
  end
end
