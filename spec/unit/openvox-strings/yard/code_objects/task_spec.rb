# frozen_string_literal: true

require 'spec_helper'
require 'openvox-strings/yard/code_objects/task'
require 'openvox-strings/yard/parsers/json/task_statement'

describe OpenvoxStrings::Yard::CodeObjects::Task do
  subject(:spec_subject) { described_class.new(statement) }

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
  let(:json) { JSON.parse(source) }
  let(:statement) { OpenvoxStrings::Yard::Parsers::JSON::TaskStatement.new(json, source, 'test.json') }

  describe '#type' do
    it 'returns the correct type' do
      expect(spec_subject.type).to eq(:puppet_task)
    end
  end

  describe '#source' do
    it 'returns the source' do
      expect(spec_subject.source).to eq(source)
    end
  end

  describe '#to_hash' do
    let(:expected) do
      {
        name: 'test',
        supports_noop: false,
        docstring: {
          text: 'Allows you to backup your database to local file.',
          tags: [
            {
              name: 'database',
              tag_name: 'param',
              text: 'Database to connect to',
              types: ['Optional[String[1]]'],
            },
            {
              name: 'user',
              tag_name: 'param',
              text: 'The user',
              types: ['Optional[String[1]]'],
            },
            {
              name: 'password',
              tag_name: 'param',
              text: 'The password',
              types: ['Optional[String[1]]'],
            },
            {
              name: 'sql',
              tag_name: 'param',
              text: 'Path to file you want backup to',
              types: ['String[1]'],
            },
          ],
        },
        file: 'test.json',
        input_method: 'stdin',
        line: 0,
        source: "{\n  \"description\": \"Allows you to backup your database to local file.\",\n  \"input_method\": \"stdin\",\n  \"parameters\": {\n    \"database\": {\n      \"description\": \"Database to connect to\",\n      \"type\": \"Optional[String[1]]\"\n    },\n    \"user\": {\n      \"description\": \"The user\",\n      \"type\": \"Optional[String[1]]\"\n    },\n    \"password\": {\n      \"description\": \"The password\",\n      \"type\": \"Optional[String[1]]\"\n    },\n     \"sql\": {\n      \"description\": \"Path to file you want backup to\",\n      \"type\": \"String[1]\"\n    }\n  }\n}\n", # rubocop:disable Layout/LineLength
      }
    end

    it 'returns the correct hash' do
      expect(spec_subject.to_hash).to eq(expected)
    end
  end
end
