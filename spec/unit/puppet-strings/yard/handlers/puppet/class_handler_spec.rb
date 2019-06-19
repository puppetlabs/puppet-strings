require 'spec_helper'
require 'puppet-strings/yard'

describe PuppetStrings::Yard::Handlers::Puppet::ClassHandler do
  subject {
    YARD::Parser::SourceParser.parse_string(source, :puppet)
    YARD::Registry.all(:puppet_class)
  }

  describe 'parsing source without a class definition' do
    let(:source) { 'notice hi' }

    it 'no classes should be in the registry' do
      expect(subject.empty?).to eq(true)
    end
  end

  describe 'parsing source with a syntax error' do
    let(:source) { 'class foo{' }

    it 'should log an error' do
      expect{ subject }.to output(/\[error\]: Failed to parse \(stdin\): Syntax error at end of (file|input)/).to_stdout_from_any_process
      expect(subject.empty?).to eq(true)
    end
  end

  describe 'parsing a class with a missing docstring' do
    let(:source) { 'class foo{}' }

    it 'should log a warning' do
      expect{ subject }.to output(/\[warn\]: Missing documentation for Puppet class 'foo' at \(stdin\):1\./).to_stdout_from_any_process
    end
  end

  describe 'parsing a class with a docstring' do
    let(:source) { <<-SOURCE
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

    it 'should register a class object' do
      expect(subject.size).to eq(1)
      object = subject.first
      expect(object).to be_a(PuppetStrings::Yard::CodeObjects::Class)
      expect(object.namespace).to eq(PuppetStrings::Yard::CodeObjects::Classes.instance)
      expect(object.name).to eq(:foo)
      expect(object.statement).not_to eq(nil)
      expect(object.parameters).to eq([['param1', nil], ['param2', nil], ['param3', 'hi']])
      expect(object.docstring).to eq('A simple foo class.')
      expect(object.docstring.tags.size).to eq(4)
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
      tags = object.docstring.tags(:api)
      expect(tags.size).to eq(1)
      expect(tags[0].text).to eq('public')
    end
  end

  describe 'parsing a class with a missing parameter' do
    let(:source) { <<-SOURCE
# A simple foo class.
# @param param1 First param.
# @param param2 Second param.
# @param param3 Third param.
# @param param4 missing!
class foo(Integer $param1, $param2, String $param3 = hi) inherits foo::bar {
  file { '/tmp/foo':
    ensure => present
  }
}
    SOURCE
    }

    it 'should output a warning' do
      expect{ subject }.to output(/\[warn\]: The @param tag for parameter 'param4' has no matching parameter at \(stdin\):6\./).to_stdout_from_any_process
    end
  end

  describe 'parsing a class with a missing @param tag' do
    let(:source) { <<-SOURCE
# A simple foo class.
# @param param1 First param.
# @param param2 Second param.
class foo(Integer $param1, $param2, String $param3 = hi) inherits foo::bar {
  file { '/tmp/foo':
    ensure => present
  }
}
    SOURCE
    }

    it 'should output a warning' do
      expect{ subject }.to output(/\[warn\]: Missing @param tag for parameter 'param3' near \(stdin\):4\./).to_stdout_from_any_process
    end
  end

  describe 'parsing a class with a typed parameter that also has a @param tag type which matches' do
    let(:source) { <<-SOURCE
# A simple foo class.
# @param [Integer] param1 First param.
# @param param2 Second param.
# @param param3 Third param.
class foo(Integer $param1, $param2, String $param3 = hi) inherits foo::bar {
  file { '/tmp/foo':
    ensure => present
  }
}
    SOURCE
    }

    it 'should respect the type that was documented' do
      expect{ subject }.to output('').to_stdout_from_any_process
      expect(subject.size).to eq(1)
      tags = subject.first.tags(:param)
      expect(tags.size).to eq(3)
      expect(tags[0].types).to eq(['Integer'])
    end
  end

  describe 'parsing a class with a typed parameter that also has a @param tag type which does not match' do
    let(:source) { <<-SOURCE
# A simple foo class.
# @param [Boolean] param1 First param.
# @param param2 Second param.
# @param param3 Third param.
class foo(Integer $param1, $param2, String $param3 = hi) inherits foo::bar {
  file { '/tmp/foo':
    ensure => present
  }
}
    SOURCE
    }

    it 'should output a warning' do
      expect{ subject }.to output(/\[warn\]: The type of the @param tag for parameter 'param1' does not match the parameter type specification near \(stdin\):5: ignoring in favor of parameter type information./).to_stdout_from_any_process
    end
  end

  describe 'parsing a class with a untyped parameter that also has a @param tag type' do
    let(:source) { <<-SOURCE
# A simple foo class.
# @param param1 First param.
# @param [Boolean] param2 Second param.
# @param param3 Third param.
class foo(Integer $param1, $param2, String $param3 = hi) inherits foo::bar {
  file { '/tmp/foo':
    ensure => present
  }
}
    SOURCE
    }

    it 'should respect the type that was documented' do
      expect{ subject }.to output('').to_stdout_from_any_process
      expect(subject.size).to eq(1)
      tags = subject.first.tags(:param)
      expect(tags.size).to eq(3)
      expect(tags[1].types).to eq(['Boolean'])
    end
  end

  describe 'parsing a class with a summary' do
    context 'when the summary has fewer than 140 characters' do
      let(:source) { <<-SOURCE
  # A simple foo class.
  # @summary A short summary.
  class foo() {
    file { '/tmp/foo':
      ensure => present
    }
  }
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
  # A simple foo class.
  # @summary A short summary that is WAY TOO LONG. AHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH this is not what a summary is for! It should be fewer than 140 characters!!
  class foo() {
    file { '/tmp/foo':
      ensure => present
    }
  }
      SOURCE
      }

      it 'should log a warning' do
        expect{ subject }.to output(/\[warn\]: The length of the summary for puppet_class 'foo' exceeds the recommended limit of 140 characters./).to_stdout_from_any_process
      end
    end
  end
end
