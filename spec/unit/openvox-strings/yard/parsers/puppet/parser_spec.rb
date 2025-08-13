# frozen_string_literal: true

require 'spec_helper'
require 'openvox-strings/yard'

describe OpenvoxStrings::Yard::Parsers::Puppet::Parser do
  subject(:spec_subject) { described_class.new(source, file) }

  let(:file) { 'test.pp' }

  describe 'initialization of the parser' do
    let(:source) { 'notice hi' }

    it 'stores the original source' do
      expect(spec_subject.source).to eq(source)
    end

    it 'stores the original file name' do
      expect(spec_subject.file).to eq(file)
    end

    it 'has no relevant statements' do
      spec_subject.parse
      expect(spec_subject.enumerator).to be_empty
    end
  end

  describe 'parsing invalid Puppet source code' do
    let(:source) { <<~SOURCE }
      class foo {
    SOURCE

    it 'raises an exception' do
      expect { spec_subject.parse }.to output(/\[error\]: Failed to parse test.pp: Syntax error at end of (file|input)/).to_stdout_from_any_process
    end
  end

  describe 'parsing class definitions' do
    let(:source) { <<~SOURCE }
      notice hello
      # A simple foo class.
      # @param param1 First param.
      # @param param2 Second param.
      # @param param3 Third param.
      class foo(Integer $param1, $param2, String $param3 = hi) inherits foo::bar {
        file { '/tmp/foo':
          ensure => present
        }
      }
    SOURCE

    it 'onlies return the class statement' do
      spec_subject.parse
      expect(spec_subject.enumerator.size).to eq(1)
      statement = spec_subject.enumerator.first
      expect(statement).to be_a(OpenvoxStrings::Yard::Parsers::Puppet::ClassStatement)
      expect(statement.source).to eq("class foo(Integer $param1, $param2, String $param3 = hi) inherits foo::bar {\n  file { '/tmp/foo':\n    ensure => present\n  }\n}")
      expect(statement.file).to eq(file)
      expect(statement.line).to eq(6)
      expect(statement.docstring).to eq('A simple foo class.')
      expect(statement.name).to eq('foo')
      expect(statement.parent_class).to eq('foo::bar')
      expect(statement.parameters.size).to eq(3)
      expect(statement.parameters[0].name).to eq('param1')
      expect(statement.parameters[0].type).to eq('Integer')
      expect(statement.parameters[0].value).to be_nil
      expect(statement.parameters[1].name).to eq('param2')
      expect(statement.parameters[1].type).to be_nil
      expect(statement.parameters[1].value).to be_nil
      expect(statement.parameters[2].name).to eq('param3')
      expect(statement.parameters[2].type).to eq('String')
      expect(statement.parameters[2].value).to eq('hi')
    end
  end

  describe 'parsing nested class definitions' do
    let(:source) { <<~SOURCE }
      class foo {
        class bar {
        }
      }
    SOURCE

    it 'parses both class statements' do
      spec_subject.parse
      expect(spec_subject.enumerator.size).to eq(2)
      statement = spec_subject.enumerator[0]
      expect(statement).to be_a(OpenvoxStrings::Yard::Parsers::Puppet::ClassStatement)
      expect(statement.name).to eq('foo::bar')
      expect(statement.parameters.size).to eq(0)
      statement = spec_subject.enumerator[1]
      expect(statement).to be_a(OpenvoxStrings::Yard::Parsers::Puppet::ClassStatement)
      expect(statement.name).to eq('foo')
      expect(statement.parameters.size).to eq(0)
    end
  end

  describe 'parsing defined types' do
    let(:source) { <<~SOURCE }
      notice hello
      # A simple foo defined type.
      # @param param1 First param.
      # @param param2 Second param.
      # @param param3 Third param.
      define foo(Integer $param1, $param2, String $param3 = hi) {
        file { '/tmp/foo':
          ensure => present
        }
      }
    SOURCE

    it 'parses the defined type statement' do
      spec_subject.parse
      expect(spec_subject.enumerator.size).to eq(1)
      statement = spec_subject.enumerator.first
      expect(statement).to be_a(OpenvoxStrings::Yard::Parsers::Puppet::DefinedTypeStatement)
      expect(statement.name).to eq('foo')
      expect(statement.source).to eq("define foo(Integer $param1, $param2, String $param3 = hi) {\n  file { '/tmp/foo':\n    ensure => present\n  }\n}")
      expect(statement.file).to eq(file)
      expect(statement.line).to eq(6)
      expect(statement.docstring).to eq('A simple foo defined type.')
      expect(statement.parameters.size).to eq(3)
      expect(statement.parameters[0].name).to eq('param1')
      expect(statement.parameters[0].type).to eq('Integer')
      expect(statement.parameters[0].value).to be_nil
      expect(statement.parameters[1].name).to eq('param2')
      expect(statement.parameters[1].type).to be_nil
      expect(statement.parameters[1].value).to be_nil
      expect(statement.parameters[2].name).to eq('param3')
      expect(statement.parameters[2].type).to eq('String')
      expect(statement.parameters[2].value).to eq('hi')
    end
  end

  describe 'parsing puppet plans', if: TEST_PUPPET_PLANS do
    # The parsing code actually checks this and sets a global (Puppet[:tasks]).
    # Plan parsing will fail if it hasn't yet encountered a file under plans/.
    let(:file) { 'plans/test.pp' }
    let(:source) { <<~SOURCE }
      # A simple plan.
      # @param param1 First param.
      # @param param2 Second param.
      # @param param3 Third param.
      plan plann(String $param1, $param2, Integer $param3 = 1) {
      }
    SOURCE

    it 'parses the puppet plan statement' do
      spec_subject.parse
      expect(spec_subject.enumerator.size).to eq(1)
      statement = spec_subject.enumerator.first
      expect(statement).to be_a(OpenvoxStrings::Yard::Parsers::Puppet::PlanStatement)
      expect(statement.name).to eq('plann')
      expect(statement.source).to eq(source.sub(/\A.*?\n([^#])/m, '\1').chomp)
      expect(statement.file).to eq(file)
      expect(statement.line).to eq(5)
      expect(statement.docstring).to eq('A simple plan.')
      expect(statement.parameters.size).to eq(3)
      expect(statement.parameters[0].name).to eq('param1')
      expect(statement.parameters[0].type).to eq('String')
      expect(statement.parameters[0].value).to be_nil
      expect(statement.parameters[1].name).to eq('param2')
      expect(statement.parameters[1].type).to be_nil
      expect(statement.parameters[1].value).to be_nil
      expect(statement.parameters[2].name).to eq('param3')
      expect(statement.parameters[2].type).to eq('Integer')
      expect(statement.parameters[2].value).to eq('1')
    end
  end

  describe 'parsing puppet functions', if: TEST_PUPPET_FUNCTIONS do
    let(:source) { <<~SOURCE }
      notice hello
      # A simple foo function.
      # @param param1 First param.
      # @param param2 Second param.
      # @param param3 Third param.
      function foo(Integer $param1, $param2, String $param3 = hi) {
        notice world
      }
    SOURCE

    it 'parses the puppet function statement' do
      spec_subject.parse
      expect(spec_subject.enumerator.size).to eq(1)
      statement = spec_subject.enumerator.first
      expect(statement).to be_a(OpenvoxStrings::Yard::Parsers::Puppet::FunctionStatement)
      expect(statement.name).to eq('foo')
      expect(statement.source).to eq("function foo(Integer $param1, $param2, String $param3 = hi) {\n  notice world\n}")
      expect(statement.file).to eq(file)
      expect(statement.line).to eq(6)
      expect(statement.docstring).to eq('A simple foo function.')
      expect(statement.parameters.size).to eq(3)
      expect(statement.parameters[0].name).to eq('param1')
      expect(statement.parameters[0].type).to eq('Integer')
      expect(statement.parameters[0].value).to be_nil
      expect(statement.parameters[1].name).to eq('param2')
      expect(statement.parameters[1].type).to be_nil
      expect(statement.parameters[1].value).to be_nil
      expect(statement.parameters[2].name).to eq('param3')
      expect(statement.parameters[2].type).to eq('String')
      expect(statement.parameters[2].value).to eq('hi')
    end
  end

  describe 'parsing puppet functions with return type in defintion', if: TEST_FUNCTION_RETURN_TYPE do
    let(:source) { <<~SOURCE }
      # A simple foo function.
      # @return Returns a string
      function foo() >> String {
        notice world
      }
    SOURCE

    it 'parses the puppet function statement' do
      spec_subject.parse
      expect(spec_subject.enumerator.size).to eq(1)
      statement = spec_subject.enumerator.first
      expect(statement).to be_a(OpenvoxStrings::Yard::Parsers::Puppet::FunctionStatement)
      expect(statement.type).to eq('String')
    end
  end

  describe 'parsing puppet functions with complex return types in defintion', if: TEST_FUNCTION_RETURN_TYPE do
    let(:source) { <<~SOURCE }
      # A simple foo function.
      # @return Returns a struct with a hash including one key which must be an integer between 1 and 10.
      function foo() >> Struct[{'a' => Integer[1, 10]}] {
        notice world
      }
    SOURCE

    it 'parses the puppet function statement' do
      spec_subject.parse
      expect(spec_subject.enumerator.size).to eq(1)
      statement = spec_subject.enumerator.first
      expect(statement).to be_a(OpenvoxStrings::Yard::Parsers::Puppet::FunctionStatement)
      expect(statement.type).to eq("Struct[{'a' => Integer[1, 10]}]")
    end
  end

  describe 'parsing type alias definitions', if: TEST_PUPPET_DATATYPES do
    context 'given a type alias on a single line' do
      let(:source) { <<~SOURCE }
        # A simple foo type.
        type Module::Typename = Variant[Stdlib::Windowspath, Stdlib::Unixpath]
      SOURCE

      it 'parses the puppet type statement' do
        spec_subject.parse
        expect(spec_subject.enumerator.size).to eq(1)
        statement = spec_subject.enumerator.first
        expect(statement).to be_a(OpenvoxStrings::Yard::Parsers::Puppet::DataTypeAliasStatement)
        expect(statement.docstring).to eq('A simple foo type.')
        expect(statement.name).to eq('Module::Typename')
        expect(statement.alias_of).to eq('Variant[Stdlib::Windowspath, Stdlib::Unixpath]')
      end
    end

    context 'given a type alias over multiple lines' do
      let(:source) { <<~SOURCE }
        # A multiline foo type
        # with long docs
        type OptionsWithoutName = Struct[{
          value_type => Optional[ValueType],
          merge      => Optional[MergeType]
        }]
      SOURCE

      it 'parses the puppet type statement' do
        spec_subject.parse
        expect(spec_subject.enumerator.size).to eq(1)
        statement = spec_subject.enumerator.first
        expect(statement).to be_a(OpenvoxStrings::Yard::Parsers::Puppet::DataTypeAliasStatement)
        expect(statement.docstring).to eq("A multiline foo type\nwith long docs")
        expect(statement.name).to eq('OptionsWithoutName')
        expect(statement.alias_of).to eq("Struct[{\n  value_type => Optional[ValueType],\n  merge      => Optional[MergeType]\n}]")
      end
    end
  end

  [
    'undef',
    'true',
    '-1',
    '0.34',
    'bareword',
    "'single quotes'",
    '"double quotes"',
    '[]',
    '[1]',
    '{}',
    '{ a => 1 }',
    '$param1',
    '1 + 1',
    'func()',
    '$param1.foo(1)',
    '$param1.foo($param2 + $param3.bar())',
  ].each do |value|
    describe "parsing parameter with #{value} default value" do
      let(:source) { <<~PUPPET }
        class foo (
          $param1 = #{value},
        ) {}
      PUPPET

      it 'finds correct value' do
        spec_subject.parse
        statement = spec_subject.enumerator.first
        expect(statement.parameters.size).to eq(1)
        expect(statement.parameters[0].value).to eq(value)
      end
    end
  end

  [
    '$param1.foo()',
    "$facts['kernel'] ? {
        'Linux'  => 'linux',
        'Darwin' => 'darwin',
        default  => $facts['kernel'],
      }",
  ].each do |value|
    describe "parsing parameter with #{value} default value" do
      let(:source) { <<~PUPPET }
        class foo (
          $param1 = #{value},
        ) {}
      PUPPET

      it 'finds correct value' do
        skip('Broken by https://tickets.puppetlabs.com/browse/PUP-11632')
        spec_subject.parse
        statement = spec_subject.enumerator.first
        expect(statement.parameters.size).to eq(1)
        expect(statement.parameters[0].value).to eq(value)
      end
    end
  end
end
