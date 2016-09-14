require 'spec_helper'
require 'puppet-strings/yard'

describe PuppetStrings::Yard::Handlers::Ruby::ProviderHandler do
  subject {
    YARD::Parser::SourceParser.parse_string(source, :ruby)
    YARD::Registry.all(:puppet_provider)
  }

  describe 'parsing source without a provider definition' do
    let(:source) { 'puts "hi"' }

    it 'no providers should be in the registry' do
      expect(subject.empty?).to eq(true)
    end
  end

  describe 'parsing a provider with a missing description' do
    let(:source) { <<-SOURCE
Puppet::Type.type(:custom).provide :linux do
end
SOURCE
    }

    it 'should log a warning' do
      expect{ subject }.to output(/\[warn\]: Missing a description for Puppet provider 'linux' \(resource type 'custom'\) at \(stdin\):1\./).to_stdout_from_any_process
    end
  end

  describe 'parsing a provider definition' do
    let(:source) { <<-SOURCE
Puppet::Type.type(:custom).provide :linux do
  desc 'An example provider on Linux.'
  confine kernel: 'Linux'
  confine osfamily: 'RedHat'
  defaultfor kernel: 'Linux'
  has_feature :implements_some_feature
  has_feature :some_other_feature
  commands foo: /usr/bin/foo
end
SOURCE
    }

    it 'should register a provider object' do
      expect(subject.size).to eq(1)
      object = subject.first
      expect(object).to be_a(PuppetStrings::Yard::CodeObjects::Provider)
      expect(object.namespace).to eq(PuppetStrings::Yard::CodeObjects::Providers.instance('custom'))
      expect(object.name).to eq(:linux)
      expect(object.type_name).to eq('custom')
      expect(object.docstring).to eq('An example provider on Linux.')
      expect(object.docstring.tags.size).to eq(1)
      tags = object.docstring.tags(:api)
      expect(tags.size).to eq(1)
      expect(tags[0].text).to eq('public')
      expect(object.confines).to eq({ 'kernel' => 'Linux', 'osfamily' => 'RedHat'})
      expect(object.defaults).to eq({ 'kernel' => 'Linux'})
      expect(object.features).to eq(['implements_some_feature', 'some_other_feature'])
      expect(object.commands).to eq({'foo' => '/usr/bin/foo'})
    end
  end
end
