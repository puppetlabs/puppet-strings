require 'spec_helper'
require 'puppet-strings/yard'

describe PuppetStrings::Yard::Parsers::JSON::Parser do
  subject { PuppetStrings::Yard::Parsers::JSON::Parser.new(source, file) }
  let(:file) { 'test.json' }

  describe 'initialization of the parser' do
    let(:source) { '{}' }

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

  describe 'parsing invalid JSON' do
    let(:source) { <<SOURCE
class foo {
SOURCE
    }

    it 'should raise an exception' do
      expect{ subject.parse }.to output(/\[error\]: Failed to parse test.json/).to_stdout_from_any_process
    end
  end


  describe 'parsing valid task metadata JSON' do
    let(:source) { <<SOURCE
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
    }
    it 'should parse the JSON and extract a TaskStatement' do
      subject.parse

      expect(subject.enumerator.size).to eq(1)
      statement = subject.enumerator.first
      expect(statement).to be_instance_of(PuppetStrings::Yard::Parsers::JSON::TaskStatement)
    end
  end
end
