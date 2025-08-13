# frozen_string_literal: true

require 'spec_helper'
require 'openvox-strings/yard'

class NullLogger
  def write(_message); end
end

describe OpenvoxStrings::Yard::Handlers::Ruby::DataTypeHandler, if: TEST_PUPPET_DATATYPES do
  subject(:spec_subject) do
    YARD::Parser::SourceParser.parse_string(source, :ruby)
    YARD::Registry.all(:puppet_data_type)
  end

  # Tests may suppress logging to make it easier to read results,
  # so remember the logging object prior to running the test.
  original_yard_logging_object = YARD::Logger.instance.io

  after do
    # Restore the original logging IO object
    YARD::Logger.instance.io = original_yard_logging_object
  end

  def suppress_yard_logging
    YARD::Logger.instance.io = NullLogger.new
  end

  describe 'parsing source without a data type definition' do
    let(:source) { 'puts "hi"' }

    it 'no data types should be in the registry' do
      expect(spec_subject.empty?).to be(true)
    end
  end

  describe 'parsing an empty data type definition' do
    let(:source) { <<~SOURCE }
      Puppet::DataTypes.create_type('RubyDataType') do
      end
    SOURCE

    it 'registers a data type object with no param tags or functions' do
      expect(spec_subject.size).to eq(1)
      object = spec_subject.first
      expect(object).to be_a(OpenvoxStrings::Yard::CodeObjects::DataType)
      expect(object.namespace).to eq(OpenvoxStrings::Yard::CodeObjects::DataTypes.instance)
      expect(object.name).to eq(:RubyDataType)
      expect(object.docstring).to eq('')
      expect(object.docstring.tags.size).to eq(1)
      tags = object.docstring.tags(:api)
      expect(tags.size).to eq(1)
      expect(tags[0].text).to eq('public')

      expect(object.parameters.size).to eq(0)
      expect(object.functions.size).to eq(0)
    end
  end

  describe 'parsing a data type definition with missing param tags' do
    let(:source) { <<~SOURCE }
      # An example Puppet Data Type in Ruby.
      Puppet::DataTypes.create_type('RubyDataType') do
        interface <<~'PUPPET'
          attributes => {
            msg => String[1],
          }
        PUPPET
      end
    SOURCE

    it 'outputs a warning' do
      expect { spec_subject }.to output(/\[warn\]: Missing @param tag for attribute 'msg' near \(stdin\):2/).to_stdout_from_any_process
    end

    it 'registers a data type object with all param tags' do
      suppress_yard_logging

      expect(spec_subject.size).to eq(1)
      object = spec_subject.first
      expect(object).to be_a(OpenvoxStrings::Yard::CodeObjects::DataType)
      expect(object.namespace).to eq(OpenvoxStrings::Yard::CodeObjects::DataTypes.instance)
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

  describe 'parsing a data type definition with missing function' do
    context 'which has parameters' do
      let(:source) { <<~SOURCE }
        # An example Puppet Data Type in Ruby.
        Puppet::DataTypes.create_type('RubyDataType') do
          interface <<~'PUPPET'
            functions => {
              func1 => Callable[[Integer, String], String]
            }
          PUPPET
        end
      SOURCE

      it 'outputs a warning about the missing functions' do
        expect { spec_subject }.to output(/\[warn\]: Missing @!method tag for function 'func1' near \(stdin\):2/m).to_stdout_from_any_process
      end

      it 'registers a data type object with all functions' do
        suppress_yard_logging

        expect(spec_subject.size).to eq(1)
        object = spec_subject.first
        expect(object).to be_a(OpenvoxStrings::Yard::CodeObjects::DataType)
        expect(object.namespace).to eq(OpenvoxStrings::Yard::CodeObjects::DataTypes.instance)
        expect(object.name).to eq(:RubyDataType)
        expect(object.docstring).to eq('An example Puppet Data Type in Ruby.')
        expect(object.docstring.tags.size).to eq(1)
        tags = object.docstring.tags(:api)
        expect(tags.size).to eq(1)
        expect(tags[0].text).to eq('public')

        # Check for functions
        expect(object.functions.size).to eq(1)
        func = object.functions.first
        expect(func.docstring).to eq('')
        expect(func.signature).to eq('RubyDataType.func1(param1, param2)')
        expect(func.tag(:return)).not_to be_nil
        expect(func.tag(:return).types).to eq(['String'])
        param_tags = func.docstring.tags(:param)
        expect(param_tags.size).to eq(2)
        expect(param_tags[0].name).to eq('param1')
        expect(param_tags[0].text).to eq('')
        expect(param_tags[0].types).to eq(['Integer'])
        expect(param_tags[1].name).to eq('param2')
        expect(param_tags[1].text).to eq('')
        expect(param_tags[1].types).to eq(['String'])
      end

      context 'which has multiple functions' do
        let(:source) { <<~SOURCE }
          # An example Puppet Data Type in Ruby.
          Puppet::DataTypes.create_type('RubyDataType') do
            interface <<~'PUPPET'
              functions => {
                func1 => Callable[[], String],
                func2 => Callable[[Integer], String]
              }
            PUPPET
          end
        SOURCE

        it 'outputs a warning about the first missing function' do
          expect { spec_subject }.to output(/\[warn\]: Missing @!method tag for function 'func1' near \(stdin\):2/m).to_stdout_from_any_process
        end

        it 'outputs a warning about the second missing function' do
          expect { spec_subject }.to output(/\[warn\]: Missing @!method tag for function 'func2' near \(stdin\):2/m).to_stdout_from_any_process
        end

        it 'registers a data type object with all functions' do
          suppress_yard_logging

          expect(spec_subject.size).to eq(1)
          object = spec_subject.first
          expect(object).to be_a(OpenvoxStrings::Yard::CodeObjects::DataType)

          # Check for functions
          expect(object.functions.size).to eq(2)
          # A function with no parmeters
          func = object.functions.first
          expect(func.signature).to eq('RubyDataType.func1')
          expect(func.tag(:return).types).to eq(['String'])
          param_tags = func.docstring.tags(:param)
          expect(param_tags).to be_empty

          # A function with one parmeter
          func = object.functions.last
          expect(func.signature).to eq('RubyDataType.func2(param1)')
          expect(func.tag(:return).types).to eq(['String'])
          param_tags = func.docstring.tags(:param)
          expect(param_tags.size).to eq(1)
        end
      end
    end
  end

  describe 'parsing a data type definition with extra tags' do
    let(:source) { <<~SOURCE }
      # An example Puppet Data Type in Ruby.
      # @param msg A message parameter.
      # @param arg1 Optional String parameter. Defaults to 'param'.
      #
      # @!method does_not_exist
      #
      Puppet::DataTypes.create_type('RubyDataType') do
        interface <<~'PUPPET'
          attributes => {
            msg => Numeric,
          },
          functions => {
            func1 => Callable[[], Optional[String]]
          }
        PUPPET
      end
    SOURCE

    it 'outputs a warning about the extra attribute' do
      expect { spec_subject }.to output(/\[warn\]: The @param tag for 'arg1' has no matching attribute near \(stdin\):7/m).to_stdout_from_any_process
    end

    it 'outputs a warning about the extra function' do
      expect { spec_subject }.to output(/\[warn\]: The @!method tag for 'does_not_exist' has no matching function definition near \(stdin\):7/m).to_stdout_from_any_process
    end

    it 'registers a data type object with extra information removed' do
      suppress_yard_logging

      expect(spec_subject.size).to eq(1)
      object = spec_subject.first
      expect(object).to be_a(OpenvoxStrings::Yard::CodeObjects::DataType)
      expect(object.namespace).to eq(OpenvoxStrings::Yard::CodeObjects::DataTypes.instance)
      expect(object.name).to eq(:RubyDataType)
      expect(object.docstring).to eq('An example Puppet Data Type in Ruby.')
      expect(object.docstring.tags.size).to eq(2)
      tags = object.docstring.tags(:api)
      expect(tags.size).to eq(1)
      expect(tags[0].text).to eq('public')

      # Check that the extra param tags are removed
      tags = object.docstring.tags(:param)
      expect(tags.size).to eq(1)
      expect(tags[0].name).to eq('msg')
      expect(tags[0].text).to eq('A message parameter.')
      expect(tags[0].types).to eq(['Numeric'])

      # Check that only the actual attributes appear
      expect(object.parameters.size).to eq(1)
      expect(object.parameters[0]).to eq(['msg', nil])

      # Check that the extra functions are removed
      meths = object.meths
      expect(meths.size).to eq(1)
      expect(meths[0].name).to eq(:func1)
    end
  end

  describe 'parsing a valid data type definition' do
    # TODO: What about testing for `type_parameters => {}`
    # e.g. https://github.com/puppetlabs/puppet/blob/main/lib/puppet/datatypes/error.rb
    let(:source) { <<~SOURCE }
      # An example Puppet Data Type in Ruby.
      #
      # @param msg A message parameter5.
      # @param arg1 Optional String parameter5. Defaults to 'param'.
      #
      # @!method func1(foo, bar)
      #   func1 documentation
      #   @param [String] foo foo documentation
      #   @param [Integer] bar bar documentation
      #   @return [Optional[String]]
      #
      Puppet::DataTypes.create_type('RubyDataType') do
        interface <<~'PUPPET'
          attributes => {
            msg   => Variant[Numeric, String[1,2]],
            arg1  => { type => Optional[String[1]], value => "param" }
          },
          functions => {
            func1 => Callable[[String, Integer], Optional[String]]
          }
        PUPPET
      end
    SOURCE

    it 'registers a data type object' do
      expect(spec_subject.size).to eq(1)
      object = spec_subject.first
      expect(object).to be_a(OpenvoxStrings::Yard::CodeObjects::DataType)
      expect(object.namespace).to eq(OpenvoxStrings::Yard::CodeObjects::DataTypes.instance)
      expect(object.name).to eq(:RubyDataType)
      expect(object.docstring).to eq('An example Puppet Data Type in Ruby.')
      expect(object.docstring.tags.size).to eq(3)
      tags = object.docstring.tags(:api)
      expect(tags.size).to eq(1)
      expect(tags[0].text).to eq('public')

      # Check that the param tags are set
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
      expect(object.parameters[1]).to eq(%w[arg1 param])

      # Check for functions
      expect(object.functions.size).to eq(1)
      func = object.functions.first
      expect(func.name).to eq(:func1)
      expect(func.docstring).to eq('func1 documentation')
      expect(func.tag(:return)).not_to be_nil
      expect(func.tag(:return).types).to eq(['Optional[String]'])
      param_tags = func.docstring.tags(:param)
      expect(param_tags.size).to eq(2)
      expect(param_tags[0].name).to eq('foo')
      expect(param_tags[0].text).to eq('foo documentation')
      expect(param_tags[0].types).to eq(['String'])
      expect(param_tags[1].name).to eq('bar')
      expect(param_tags[1].text).to eq('bar documentation')
      expect(param_tags[1].types).to eq(['Integer'])
    end

    context 'with multiple interfaces' do
      let(:source) { <<~SOURCE }
        # An example Puppet Data Type in Ruby.
        #
        # @param msg A message parameter5.
        # @param arg1 Optional String parameter5. Defaults to 'param'.
        #
        # @!method func1(param1, param2)
        #   func1 documentation
        #   @param [String] param1 param1 documentation
        #   @param [Integer] param2 param2 documentation
        #   @return [Optional[String]]
        #
        Puppet::DataTypes.create_type('RubyDataType') do
          if 1 == 2
            interface <<~'PUPPET'
              This interface is invalid because of this text!
              attributes => {
                msg1 => Variant[Numeric, String[1,2]],
              },
              functions => {
                func1 => Callable[[String, Integer], Optional[String]]
              }
            PUPPET
          elsif 1 == 3
            interface <<~'PUPPET'
              attributes => {
                msg2 => Variant[Numeric, String[1,2]],
              },
              functions => {
                func2 => Callable[[String, Integer], Optional[String]]
              }
            PUPPET
          else
            interface <<~'PUPPET'
              attributes => {
                msg3 => Variant[Numeric, String[1,2]],
              },
              functions => {
                func3 => Callable[[String, Integer], Optional[String]]
              }
            PUPPET
          end
        end
      SOURCE

      it 'registers only the first valid interface' do
        suppress_yard_logging

        expect(spec_subject.size).to eq(1)
        object = spec_subject.first
        expect(object.name).to eq(:RubyDataType)

        # Check that the param tags are set
        tags = object.docstring.tags(:param)
        expect(tags.size).to eq(1)
        expect(tags[0].name).to eq('msg2')

        # Check for functions
        expect(object.functions.size).to eq(1)
        expect(object.functions.first.name).to eq(:func2)
      end
    end

    context 'with missing, partial and addition function parameters' do
      let(:source) { <<~SOURCE }
        # An example Puppet Data Type in Ruby.
        #
        # @!method func1(foo1, foo2)
        #   func1 docs
        #   @param [String] foo1 param1 documentation
        #   @param [Integer] missing docs should exist
        #   @param [String] extra Should not exist
        #   @return [Integer] This is wrong
        #
        # @!method func2(param1, param2)
        #   func2 docs - missing a parameter
        #   @param [String] param1 param1 documentation
        #
        Puppet::DataTypes.create_type('RubyDataType') do
          interface <<~'PUPPET'
            attributes => {
            },
            functions => {
              func1 => Callable[[Integer, Integer], Optional[String]],
              func2 => Callable[[Integer, Integer], Optional[String]]
            }
          PUPPET
        end
      SOURCE

      it 'outputs a warning about the incorrect return type' do
        expect { spec_subject }.to output(/\[warn\]: The @return tag for 'func1' has a different type definition .+ Expected \["Optional\[String\]"\]/m).to_stdout_from_any_process
      end

      it 'outputs a warning about the additional parameter' do
        expect { spec_subject }.to output(/\[warn\]: The @param tag for 'extra' should not exist for function 'func1' that is defined near/m).to_stdout_from_any_process
      end

      it 'outputs a warning about the wrong parameter type (func1)' do
        expect do
          spec_subject
        end.to output(/\[warn\]: The @param tag for 'foo1' for function 'func1' has a different type definition than the actual function near .+ Expected \["Integer"\]/m).to_stdout_from_any_process
      end

      it 'outputs a warning about the wrong parameter type (func2)' do
        expect do
          spec_subject
        end.to output(/\[warn\]: The @param tag for 'param1' for function 'func2' has a different type definition than the actual function near .+ Expected \["Integer"\]/m).to_stdout_from_any_process
      end

      it 'automatically fixes function parameters, except for differring types' do
        suppress_yard_logging

        expect(spec_subject.size).to eq(1)
        object = spec_subject.first
        expect(object).to be_a(OpenvoxStrings::Yard::CodeObjects::DataType)

        # Check for functions
        expect(object.functions.size).to eq(2)

        func = object.functions.first
        expect(func.docstring).to eq('func1 docs')
        expect(func.tag(:return)).not_to be_nil
        expect(func.tag(:return).types).to eq(['Optional[String]'])
        param_tags = func.docstring.tags(:param)
        expect(param_tags.size).to eq(2)
        expect(param_tags[0].name).to eq('foo1')
        expect(param_tags[0].text).to eq('param1 documentation')
        expect(param_tags[0].types).to eq(['Integer'])
        expect(param_tags[1].name).to eq('missing')
        expect(param_tags[1].text).to eq('docs should exist')
        expect(param_tags[1].types).to eq(['Integer'])

        func = object.functions.last
        expect(func.docstring).to eq('func2 docs - missing a parameter')
        param_tags = func.docstring.tags(:param)
        expect(param_tags.size).to eq(2)
        expect(param_tags[0].name).to eq('param1')
        expect(param_tags[0].text).to eq('param1 documentation')
        expect(param_tags[0].types).to eq(['Integer'])
        expect(param_tags[1].name).to eq('param2')
        expect(param_tags[1].text).to eq('')
        expect(param_tags[1].types).to eq(['Integer'])
      end
    end
  end

  [
    { value: '-1', expected: -1 },
    { value: '0', expected: 0 },
    { value: '10', expected: 10 },
    { value: '0777', expected: 511 },
    { value: '0xFF', expected: 255 },
    { value: '0.1', expected: 0.1 },
    { value: '31.415e-1', expected: 3.1415 },
    { value: '0.31415e1', expected: 3.1415 },
  ].each do |testcase|
    describe "parsing a valid data type definition with numeric default #{testcase[:value]}" do
      let(:source) { <<~SOURCE }
        # An example Puppet Data Type in Ruby.
        # @param num1 A numeric parameter
        Puppet::DataTypes.create_type('RubyDataType') do
          interface <<~'PUPPET'
            attributes => {
              num1 => { type => Numeric, value => #{testcase[:value]} },
            }
          PUPPET
        end
      SOURCE

      it 'registers a data type object' do
        expect(spec_subject.size).to eq(1)
        object = spec_subject.first
        expect(object).to be_a(OpenvoxStrings::Yard::CodeObjects::DataType)
        expect(object.parameters.size).to eq(1)
        expect(object.parameters[0]).to eq(['num1', testcase[:expected]])
      end
    end
  end

  describe 'parsing an invalid data type definition' do
    let(:source) { <<~SOURCE }
      # The msg attribute is missing a comma.
      #
      # @param msg A message parameter5.
      # @param arg1 Optional String parameter5. Defaults to 'param'.
      Puppet::DataTypes.create_type('RubyDataType') do
        interface <<~'PUPPET'
          attributes => {
            msg   => Variant[Numeric, String[1,2]]
            arg1  => { type => Optional[String[1]], value => "param" }
          },
          functions => {
            func1 => Callable[[], Integer]
          }
        PUPPET
      end
    SOURCE

    it 'registers a partial data type object' do
      suppress_yard_logging

      expect(spec_subject.size).to eq(1)
      object = spec_subject.first
      expect(object).to be_a(OpenvoxStrings::Yard::CodeObjects::DataType)
      expect(object.namespace).to eq(OpenvoxStrings::Yard::CodeObjects::DataTypes.instance)
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

      # Check for functions
      expect(object.functions.size).to eq(0)
    end

    it 'logs a warning' do
      expect { spec_subject }.to output(/\[warn\]: Invalid datatype definition at (.+):[0-9]+: Syntax error at 'arg1'/).to_stdout_from_any_process
    end
  end

  describe 'parsing a data type with a summary' do
    context 'when the summary has fewer than 140 characters' do
      let(:source) { <<~SOURCE }
        # An example Puppet Data Type in Ruby.
        #
        # @summary A short summary.
        Puppet::DataTypes.create_type('RubyDataType') do
          interface <<~'PUPPET'
            attributes => { }
          PUPPET
        end
      SOURCE

      it 'parses the summary' do
        expect { spec_subject }.not_to output.to_stdout_from_any_process
        expect(spec_subject.size).to eq(1)
        summary = spec_subject.first.tags(:summary)
        expect(summary.first.text).to eq('A short summary.')
      end
    end

    context 'when the summary has more than 140 characters' do
      let(:source) { <<~SOURCE }
        # An example Puppet Data Type in Ruby.
        #
        # @summary A short summary that is WAY TOO LONG. AHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH this is not what a summary is for! It should be fewer than 140 characters!!
        Puppet::DataTypes.create_type('RubyDataType') do
          interface <<~'PUPPET'
            attributes => { }
          PUPPET
        end
      SOURCE

      it 'logs a warning' do
        expect { spec_subject }.to output(/\[warn\]: The length of the summary for puppet_data_type 'RubyDataType' exceeds the recommended limit of 140 characters./).to_stdout_from_any_process
      end
    end
  end
end
