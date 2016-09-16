require 'spec_helper'
require 'puppet-strings/yard'

describe PuppetStrings::Yard::Parsers::Puppet::Parser do
  subject { PuppetStrings::Yard::Parsers::Puppet::Parser.new(source, file) }
  let(:file) { 'test.pp' }

  describe 'initialization of the parser' do
    let(:source) { 'notice hi' }

    it 'should store the original source' do
      expect(subject.source).to eq(source)
    end

    it 'should store the original file name' do
      expect(subject.file).to eq(file)
    end

    it 'should have no relevant statements' do
      subject.parse
      expect(subject.enumerator.empty?).to be_truthy
    end
  end

  describe 'parsing invalid Puppet source code' do
    let(:source) { <<SOURCE
class foo {
SOURCE
    }

    it 'should raise an exception' do
      expect{ subject.parse }.to output(/\[error\]: Failed to parse test.pp: Syntax error at end of file/).to_stdout_from_any_process
    end
  end

  describe 'parsing class definitions' do
    let(:source) { <<SOURCE
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
    }

    it 'should only return the class statement' do
      subject.parse
      expect(subject.enumerator.size).to eq(1)
      statement = subject.enumerator.first
      expect(statement).to be_a(PuppetStrings::Yard::Parsers::Puppet::ClassStatement)
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
    let(:source) { <<SOURCE
class foo {
  class bar {
  }
}
SOURCE
    }

    it 'should parse both class statements' do
      subject.parse
      expect(subject.enumerator.size).to eq(2)
      statement = subject.enumerator[0]
      expect(statement).to be_a(PuppetStrings::Yard::Parsers::Puppet::ClassStatement)
      expect(statement.name).to eq('foo::bar')
      expect(statement.parameters.size).to eq(0)
      statement = subject.enumerator[1]
      expect(statement).to be_a(PuppetStrings::Yard::Parsers::Puppet::ClassStatement)
      expect(statement.name).to eq('foo')
      expect(statement.parameters.size).to eq(0)
    end
  end

  describe 'parsing defined types' do
    let(:source) { <<SOURCE
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
    }

    it 'should parse the defined type statement' do
      subject.parse
      expect(subject.enumerator.size).to eq(1)
      statement = subject.enumerator.first
      expect(statement).to be_a(PuppetStrings::Yard::Parsers::Puppet::DefinedTypeStatement)
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

  describe 'parsing puppet functions', if: TEST_PUPPET_FUNCTIONS do
    let(:source) { <<SOURCE
notice hello
# A simple foo function.
# @param param1 First param.
# @param param2 Second param.
# @param param3 Third param.
function foo(Integer $param1, $param2, String $param3 = hi) {
  notice world
}
SOURCE
    }

    it 'should parse the puppet function statement' do
      subject.parse
      expect(subject.enumerator.size).to eq(1)
      statement = subject.enumerator.first
      expect(statement).to be_a(PuppetStrings::Yard::Parsers::Puppet::FunctionStatement)
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
end
