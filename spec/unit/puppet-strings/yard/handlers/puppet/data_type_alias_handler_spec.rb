# frozen_string_literal: true

require 'spec_helper'
require 'puppet-strings/yard'

describe PuppetStrings::Yard::Handlers::Puppet::DataTypeAliasHandler, if: TEST_PUPPET_DATATYPES do
  subject(:spec_subject) do
    YARD::Parser::SourceParser.parse_string(source, :puppet)
    YARD::Registry.all(:puppet_data_type_alias)
  end

  describe 'parsing source without a type alias definition' do
    let(:source) { 'notice hi' }

    it 'no aliases should be in the registry' do
      expect(spec_subject.empty?).to be(true)
    end
  end

  describe 'parsing source with a syntax error' do
    let(:source) { 'type Testype =' }

    it 'logs an error' do
      expect { spec_subject }.to output(%r{\[error\]: Failed to parse \(stdin\): Syntax error at end of (file|input)}).to_stdout_from_any_process
      expect(spec_subject.empty?).to be(true)
    end
  end

  describe 'parsing a data type alias with a missing docstring' do
    let(:source) { 'type Testype = String[1]' }

    it 'logs a warning' do
      expect { spec_subject }.to output(%r{\[warn\]: Missing documentation for Puppet type alias 'Testype' at \(stdin\):1\.}).to_stdout_from_any_process
    end
  end

  describe 'parsing a data type alias with a summary' do
    context 'when the summary has fewer than 140 characters' do
      let(:source) { <<~'SOURCE' }
        # A simple foo type.
        # @summary A short summary.
        type Testype = String[1]
      SOURCE

      it 'parses the summary' do
        expect { spec_subject }.to output('').to_stdout_from_any_process
        expect(spec_subject.size).to eq(1)
        summary = spec_subject.first.tags(:summary)
        expect(summary.first.text).to eq('A short summary.')
      end
    end

    context 'when the summary has more than 140 characters' do
      let(:source) { <<~'SOURCE' }
        # A simple foo type.
        # @summary A short summary that is WAY TOO LONG. AHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH this is not what a summary is for! It should be fewer than 140 characters!!
        type Testype = String[1]
      SOURCE

      it 'logs a warning' do
        expect { spec_subject }.to output(%r{\[warn\]: The length of the summary for puppet_data_type_alias 'Testype' exceeds the recommended limit of 140 characters.}).to_stdout_from_any_process
      end
    end
  end
end
