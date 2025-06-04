# frozen_string_literal: true

require 'spec_helper'
require 'openvox-strings/yard'

describe OpenvoxStrings::Yard::Handlers::Ruby::ProviderHandler do
  subject(:spec_subject) do
    YARD::Parser::SourceParser.parse_string(source, :ruby)
    YARD::Registry.all(:puppet_provider)
  end

  describe 'parsing source without a provider definition' do
    let(:source) { 'puts "hi"' }

    it 'no providers should be in the registry' do
      expect(spec_subject.empty?).to be(true)
    end
  end

  describe 'parsing a provider with a missing description' do
    let(:source) { <<~SOURCE }
      Puppet::Type.type(:custom).provide :linux do
      end
    SOURCE

    it 'logs a warning' do
      expect { spec_subject }.to output(/\[warn\]: Missing a description for Puppet provider 'linux' \(resource type 'custom'\) at \(stdin\):1\./).to_stdout_from_any_process
    end
  end

  describe 'parsing a provider with an invalid docstring assignment' do
    let(:source) { <<~SOURCE }
      Puppet::Type.type(:custom).provide :linux do
        @doc = 123
      end
    SOURCE

    it 'logs an error' do
      expect { spec_subject }.to output(/Failed to parse docstring/).to_stdout_from_any_process
    end
  end

  describe 'parsing a provider with a valid docstring assignment' do
    let(:source) { <<~SOURCE }
      Puppet::Type.type(:custom).provide :linux do
        @doc = 'An example provider on Linux.'
      end
    SOURCE

    it 'correctlies detect the docstring' do
      expect(spec_subject.size).to eq(1)
      object = spec_subject.first
      expect(object.docstring).to eq('An example provider on Linux.')
    end
  end

  describe 'parsing a provider with a docstring which uses ruby `%Q` notation' do
    let(:source) { <<~'SOURCE' }
      Puppet::Type.type(:custom).provide :linux do
        test = 'hello world!'
        desc %Q{This is a multi-line
        doc in %Q with #{test}}
      end
    SOURCE

    it 'strips the `%Q{}` and render the interpolation expression literally' do
      expect(spec_subject.size).to eq(1)
      object = spec_subject.first
      expect(object.docstring).to eq("This is a multi-line\ndoc in %Q with \#{test}")
    end
  end

  describe 'parsing a provider definition' do
    let(:source) { <<~SOURCE }
      Puppet::Type.type(:custom).provide :linux do
        desc 'An example provider on Linux.'
        confine kernel: 'Linux'
        confine osfamily: 'RedHat'
        defaultfor :kernel => 'Linux'
        defaultfor :osfamily => 'RedHat', :operatingsystemmajrelease => '7'
        has_feature :implements_some_feature
        has_feature :some_other_feature
        commands foo: '/usr/bin/foo'
      end
    SOURCE

    it 'registers a provider object' do
      expect(spec_subject.size).to eq(1)
      object = spec_subject.first
      expect(object).to be_a(OpenvoxStrings::Yard::CodeObjects::Provider)
      expect(object.namespace).to eq(OpenvoxStrings::Yard::CodeObjects::Providers.instance('custom'))
      expect(object.name).to eq(:linux)
      expect(object.type_name).to eq('custom')
      expect(object.docstring).to eq('An example provider on Linux.')
      expect(object.docstring.tags.size).to eq(1)
      tags = object.docstring.tags(:api)
      expect(tags.size).to eq(1)
      expect(tags[0].text).to eq('public')
      expect(object.confines).to eq({ 'kernel' => 'Linux', 'osfamily' => 'RedHat' })
      expect(object.defaults).to eq([[%w[kernel Linux]], [%w[osfamily RedHat], %w[operatingsystemmajrelease 7]]])
      expect(object.features).to eq(%w[implements_some_feature some_other_feature])
      expect(object.commands).to eq({ 'foo' => '/usr/bin/foo' })
    end
  end

  describe 'parsing a provider definition with a string based name' do
    let(:source) { <<~SOURCE }
      Puppet::Type.type(:'custom').provide :'linux' do
        desc 'An example provider on Linux.'
      end
    SOURCE

    it 'registers a provider object' do
      expect(spec_subject.size).to eq(1)
      object = spec_subject.first
      expect(object).to be_a(OpenvoxStrings::Yard::CodeObjects::Provider)
      expect(object.namespace).to eq(OpenvoxStrings::Yard::CodeObjects::Providers.instance('custom'))
      expect(object.name).to eq(:linux)
      expect(object.type_name).to eq('custom')
      expect(object.docstring).to eq('An example provider on Linux.')
    end
  end

  describe 'parsing a provider with a summary' do
    context 'when the summary has fewer than 140 characters' do
      let(:source) { <<~SOURCE }
        Puppet::Type.type(:custom).provide :linux do
          @doc = '@summary A short summary.'
        end
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
        Puppet::Type.type(:custom).provide :linux do
          @doc = '@summary A short summary that is WAY TOO LONG. AHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH this is not what a summary is for! It should be fewer than 140 characters!!'
        end
      SOURCE

      it 'logs a warning' do
        expect { spec_subject }.to output(/\[warn\]: The length of the summary for puppet_provider 'linux' exceeds the recommended limit of 140 characters./).to_stdout_from_any_process
      end
    end
  end
end
