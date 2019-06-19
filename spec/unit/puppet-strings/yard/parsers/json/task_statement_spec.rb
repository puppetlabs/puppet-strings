require 'spec_helper'

describe PuppetStrings::Yard::Parsers::JSON::TaskStatement do
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
  let(:json) { JSON.parse(source) }
  subject { PuppetStrings::Yard::Parsers::JSON::TaskStatement.new(json, source, "test.json") }
  describe '#comments' do
    it 'returns docstring' do
      expect(subject.comments).to eq "Allows you to backup your database to local file."
    end
  end
  describe '#parameters' do
    context 'with params' do
      it 'returns params' do
        expect(subject.parameters.size > 0).to be true
      end
    end
    context 'no params' do
      let(:source) { <<-SOURCE
{
  "description": "Allows you to backup your database to local file.",
  "input_method": "stdin"
}
      SOURCE
      }
      it 'returns an empty hash' do
        expect(subject.parameters).to eq({})
      end
    end
  end

end
