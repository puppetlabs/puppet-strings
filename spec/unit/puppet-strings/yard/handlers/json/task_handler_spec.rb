require 'spec_helper'
require 'puppet-strings/yard'

describe PuppetStrings::Yard::Handlers::JSON::TaskHandler do
  subject {
    YARD::Parser::SourceParser.parse_string(source, :json)
    YARD::Registry.all(:puppet_task)
  }

  describe 'parsing source without a task definition' do
    let(:source) { 'notice hi' }

    it 'no defined types should be in the registry' do
      expect(subject.empty?).to eq(true)
    end
  end

  describe 'parsing source with a syntax error' do
    let(:source) { <<-SOURCE
{
  "input_method": "stdin",
  "parameters":
    "database": {
      "description": "Database to connect to",
      "type": "Optional[String[1]]"
    }
  }
}
SOURCE
    }

    it 'should log an error' do
      expect{ subject }.to output(/\[error\]: Failed to parse \(stdin\):/).to_stdout_from_any_process
      expect(subject.empty?).to eq(true)
    end
  end

  describe 'parsing a defined type with a missing docstring' do
    let(:source) { <<-SOURCE
{
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

    it 'should log a warning' do
      expect{ subject }.to output(/\[warn\]: Missing a description for Puppet Task \(stdin\)/).to_stdout_from_any_process
    end
  end

  describe 'parsing a defined type with a docstring' do
    let(:source) { <<-SOURCE
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

    it 'should register a task object' do
      expect(subject.size).to eq(1)
      object = subject.first
      expect(object).to be_a(PuppetStrings::Yard::CodeObjects::Task)
      expect(object.namespace).to eq(PuppetStrings::Yard::CodeObjects::Tasks.instance)
    end
  end

  describe 'parsing a Task with a missing parameter description' do
    let(:source) { <<-SOURCE
{
  "description": "Allows you to backup your database to local file.",
  "input_method": "stdin",
  "parameters": {
    "database": {
      "type": "Optional[String[1]]"
    }
  }
}
SOURCE
    }

    it 'should output a warning' do
      expect{ subject }.to output(/\[warn\]: Missing description for param 'database' in Puppet Task \(stdin\)/).to_stdout_from_any_process
    end
  end

end
