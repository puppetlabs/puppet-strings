# frozen_string_literal: true

require 'spec_helper'
require 'openvox-strings/yard'

# Limit this spec to Puppet 4.1+ (when functions in Puppet were implemented)
describe OpenvoxStrings::Yard::Handlers::Puppet::FunctionHandler, if: TEST_PUPPET_FUNCTIONS do
  subject(:spec_subject) do
    YARD::Parser::SourceParser.parse_string(source, :puppet)
    YARD::Registry.all(:puppet_function)
  end

  describe 'parsing source without a function definition' do
    let(:source) { 'notice hi' }

    it 'no functions should be in the registry' do
      expect(spec_subject.empty?).to be(true)
    end
  end

  describe 'parsing source with a syntax error' do
    let(:source) { 'function foo{' }

    it 'logs an error' do
      expect { spec_subject }.to output(/\[error\]: Failed to parse \(stdin\): Syntax error at end of/).to_stdout_from_any_process
      expect(spec_subject.empty?).to be(true)
    end
  end

  describe 'parsing a function with a missing docstring' do
    let(:source) { 'function foo{}' }

    it 'logs a warning' do
      expect { spec_subject }.to output(/\[warn\]: Missing documentation for Puppet function 'foo' at \(stdin\):1\./).to_stdout_from_any_process
    end
  end

  describe 'parsing a function with a docstring' do
    let(:source) { <<~SOURCE }
      # A simple foo function.
      # @param param1 First param.
      # @param param2 Second param.
      # @param param3 Third param.
      # @return [Undef] Returns nothing.
      function foo(Integer $param1, $param2, String $param3 = hi) {
        notice 'hello world'
        undef
      }
    SOURCE

    it 'registers a function object' do
      expect(spec_subject.size).to eq(1)
      object = spec_subject.first
      expect(object).to be_a(OpenvoxStrings::Yard::CodeObjects::Function)
      expect(object.namespace).to eq(OpenvoxStrings::Yard::CodeObjects::Functions.instance(OpenvoxStrings::Yard::CodeObjects::Function::PUPPET))
      expect(object.name).to eq(:foo)
      expect(object.signature).to eq('foo(Integer $param1, Any $param2, String $param3 = hi)')
      expect(object.parameters).to eq([['param1', nil], ['param2', nil], %w[param3 hi]])
      expect(object.docstring).to eq('A simple foo function.')
      expect(object.docstring.tags.size).to eq(5)
      tags = object.docstring.tags(:param)
      expect(tags.size).to eq(3)
      expect(tags[0].name).to eq('param1')
      expect(tags[0].text).to eq('First param.')
      expect(tags[0].types).to eq(['Integer'])
      expect(tags[1].name).to eq('param2')
      expect(tags[1].text).to eq('Second param.')
      expect(tags[1].types).to eq(['Any'])
      expect(tags[2].name).to eq('param3')
      expect(tags[2].text).to eq('Third param.')
      expect(tags[2].types).to eq(['String'])
      tags = object.docstring.tags(:return)
      expect(tags.size).to eq(1)
      expect(tags[0].tag_name).to eq('return')
      expect(tags[0].text).to eq('Returns nothing.')
      expect(tags[0].types).to eq(['Undef'])
      tags = object.docstring.tags(:api)
      expect(tags.size).to eq(1)
      expect(tags[0].text).to eq('public')
    end
  end

  describe 'parsing a function with a missing parameter' do
    let(:source) { <<~SOURCE }
      # A simple foo function.
      # @param param1 First param.
      # @param param2 Second param.
      # @param param3 Third param.
      # @param param4 missing!
      # @return [Undef] Returns nothing.
      function foo(Integer $param1, $param2, String $param3 = hi) {
        notice 'hello world'
      }
    SOURCE

    it 'outputs a warning' do
      expect { spec_subject }
        .to output(/\[warn\]: The @param tag for parameter 'param4' has no matching parameter at \(stdin\):7\./)
        .to_stdout_from_any_process
    end
  end

  describe 'parsing a function with a missing @param tag' do
    let(:source) { <<~SOURCE }
      # A simple foo function.
      # @param param1 First param.
      # @param param2 Second param.
      # @return [Undef] Returns nothing.
      function foo(Integer $param1, $param2, String $param3 = hi) {
        notice 'hello world'
      }
    SOURCE

    it 'outputs a warning' do
      expect { spec_subject }.to output(/\[warn\]: Missing @param tag for parameter 'param3' near \(stdin\):5\./).to_stdout_from_any_process
    end
  end

  describe 'parsing a function with a typed parameter that also has a @param tag type which matches' do
    let(:source) { <<~SOURCE }
      # A simple foo function.
      # @param [Integer] param1 First param.
      # @param param2 Second param.
      # @param param3 Third param.
      # @return [Undef] Returns nothing.
      function foo(Integer $param1, $param2, String $param3 = hi) {
        notice 'hello world'
      }
    SOURCE

    it 'respects the type that was documented' do
      expect { spec_subject }.not_to output.to_stdout_from_any_process
      expect(spec_subject.size).to eq(1)
      tags = spec_subject.first.tags(:param)
      expect(tags.size).to eq(3)
      expect(tags[0].types).to eq(['Integer'])
    end
  end

  describe 'parsing a function with a typed parameter that also has a @param tag type which does not match' do
    let(:source) { <<~SOURCE }
      # A simple foo function.
      # @param [Boolean] param1 First param.
      # @param param2 Second param.
      # @param param3 Third param.
      # @return [Undef] Returns nothing.
      function foo(Integer $param1, $param2, String $param3 = hi) {
        notice 'hello world'
      }
    SOURCE

    it 'outputs a warning' do
      expect { spec_subject }
        .to output(
          /\[warn\]: The type of the @param tag for parameter 'param1' does not match the parameter type specification near \(stdin\):6: ignoring in favor of parameter type information./,
        )
        .to_stdout_from_any_process
    end
  end

  describe 'parsing a function with a untyped parameter that also has a @param tag type' do
    let(:source) { <<~SOURCE }
      # A simple foo function.
      # @param param1 First param.
      # @param [Boolean] param2 Second param.
      # @param param3 Third param.
      # @return [Undef] Returns nothing.
      function foo(Integer $param1, $param2, String $param3 = hi) {
        notice 'hello world'
      }
    SOURCE

    it 'respects the type that was documented' do
      expect { spec_subject }.not_to output.to_stdout_from_any_process
      expect(spec_subject.size).to eq(1)
      tags = spec_subject.first.tags(:param)
      expect(tags.size).to eq(3)
      expect(tags[1].types).to eq(['Boolean'])
    end
  end

  describe 'parsing a function with a missing @return tag' do
    let(:source) { <<~SOURCE }
      # A simple foo function.
      # @param param1 First param.
      # @param param2 Second param.
      # @param param3 Third param.
      function foo(Integer $param1, $param2, String $param3 = hi) {
        notice 'hello world'
      }
    SOURCE

    it 'outputs a warning' do
      expect { spec_subject }.to output(/\[warn\]: Missing @return tag near \(stdin\):5\./).to_stdout_from_any_process
    end
  end

  describe 'parsing a function with a missing @return tag and return type specified in the function definition', if: TEST_FUNCTION_RETURN_TYPE do
    let(:source) { <<~SOURCE }
      # A simple foo function.
      function foo() >> String {
        notice 'hello world'
      }
    SOURCE

    it 'registers a function object with the correct return type' do
      expect { spec_subject }.to output(/\[warn\]: Missing @return tag near \(stdin\):2\./).to_stdout_from_any_process
      expect(spec_subject.size).to eq(1)
      object = spec_subject.first
      expect(object).to be_a(OpenvoxStrings::Yard::CodeObjects::Function)
      tags = object.docstring.tags(:return)
      expect(tags.size).to eq(1)
      expect(tags[0].tag_name).to eq('return')
      expect(tags[0].text).to eq('')
      expect(tags[0].types).to eq(['String'])
    end
  end

  describe 'parsing a function with a non-conflicting return tag and type in function definition', if: TEST_FUNCTION_RETURN_TYPE do
    let(:source) { <<~SOURCE }
      # A simple foo function
      # @return [String] Hi there
      function foo() >> String {
        notice 'hi there'
      }
    SOURCE

    it 'does not output a warning if return types match' do
      expect { spec_subject }.not_to output(/Documented return type does not match return type in function definition/).to_stdout_from_any_process
    end
  end

  describe 'parsing a function with a conflicting return tag and type in function definition', if: TEST_FUNCTION_RETURN_TYPE do
    let(:source) { <<~SOURCE }
      # A simple foo function.
      # @return [Integer] this is a lie.
      function foo() >> Struct[{'a' => Integer[1, 10]}] {
        notice 'hello world'
      }
    SOURCE

    it 'prefers the return type from the function definition' do
      expect { spec_subject }.to output(/\[warn\]: Documented return type does not match return type in function definition near \(stdin\):3\./).to_stdout_from_any_process
      expect(spec_subject.size).to eq(1)
      object = spec_subject.first
      expect(object).to be_a(OpenvoxStrings::Yard::CodeObjects::Function)
      tags = object.docstring.tags(:return)
      expect(tags.size).to eq(1)
      expect(tags[0].tag_name).to eq('return')
      expect(tags[0].text).to eq('this is a lie.')
      expect(tags[0].types).to eq(["Struct[{'a' => Integer[1, 10]}]"])
    end
  end

  describe 'parsing a function with return tag without type', if: TEST_FUNCTION_RETURN_TYPE do
    let(:source) { <<~SOURCE }
      # A simple foo function.
      # @return This is something.
      function foo() >> Struct[{'a' => Integer[1, 10]}] {
        notice 'hello world'
      }
    SOURCE

    it 'gets the return type from the function definition' do
      expect { spec_subject }.not_to output.to_stdout_from_any_process
      expect(spec_subject.size).to eq(1)
      object = spec_subject.first
      expect(object).to be_a(OpenvoxStrings::Yard::CodeObjects::Function)
      tags = object.docstring.tags(:return)
      expect(tags.size).to eq(1)
      expect(tags[0].tag_name).to eq('return')
      expect(tags[0].text).to eq('This is something.')
      expect(tags[0].types).to eq(["Struct[{'a' => Integer[1, 10]}]"])
    end
  end

  describe 'parsing a function without a return tag or return type in the function definition' do
    let(:source) { <<~SOURCE }
      # A simple foo function.
      function foo() {
        notice 'hello world'
      }
    SOURCE

    it 'adds a return tag with a default type value of Any' do
      expect { spec_subject }.to output(/\[warn\]: Missing @return tag near \(stdin\):2\./).to_stdout_from_any_process
      expect(spec_subject.size).to eq(1)
      object = spec_subject.first
      expect(object).to be_a(OpenvoxStrings::Yard::CodeObjects::Function)
      tags = object.docstring.tags(:return)
      expect(tags.size).to eq(1)
      expect(tags[0].tag_name).to eq('return')
      expect(tags[0].text).to eq('')
      expect(tags[0].types).to eq(['Any'])
    end
  end

  describe 'parsing a function with a summary' do
    context 'when the summary has fewer than 140 characters' do
      let(:source) { <<~SOURCE }
        # A simple foo function.
        # @summary A short summary.
        # @return [String] foo
        function foo() {
          notice 'hello world'
        }
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
        # A simple foo function.
        # @summary A short summary that is WAY TOO LONG. AHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH this is not what a summary is for! It should be fewer than 140 characters!!
        function foo() {
          notice 'hello world'
        }

      SOURCE

      it 'logs a warning' do
        expect { spec_subject }.to output(/\[warn\]: The length of the summary for puppet_function 'foo' exceeds the recommended limit of 140 characters./).to_stdout_from_any_process
      end
    end
  end
end
