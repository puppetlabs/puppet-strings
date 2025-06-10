# frozen_string_literal: true

require 'spec_helper'
require 'openvox-strings/yard'

describe OpenvoxStrings::Yard::Parsers::JSON::Parser do
  subject(:spec_subject) { described_class.new(source, file) }

  let(:file) { 'test.json' }

  describe 'initialization of the parser' do
    let(:source) { '{}' }

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

  describe 'parsing invalid JSON' do
    let(:source) { <<~SOURCE }
      class foo {
    SOURCE

    it 'raises an exception' do
      expect { spec_subject.parse }.to output(/\[error\]: Failed to parse test.json/).to_stdout_from_any_process
    end
  end

  describe 'parsing valid task metadata JSON' do
    let(:source) { <<~SOURCE }
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

    it 'parses the JSON and extract a TaskStatement' do
      spec_subject.parse

      expect(spec_subject.enumerator.size).to eq(1)
      statement = spec_subject.enumerator.first
      expect(statement).to be_instance_of(OpenvoxStrings::Yard::Parsers::JSON::TaskStatement)
    end
  end
end
