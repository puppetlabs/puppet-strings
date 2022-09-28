# frozen_string_literal: true

require 'spec_helper'
require 'puppet-strings/yard'

describe PuppetStrings::Yard::Handlers::Ruby::TypeExtrasHandler do
  subject(:spec_subject) do
    YARD::Parser::SourceParser.parse_string(source, :ruby)
    YARD::Registry.all(:puppet_type)
  end

  describe 'parsing source with newproperty' do
    let(:source) do
      <<~SOURCE
      Puppet::Type.newtype(:database) do
        desc 'database'
      end
      Puppet::Type.type(:database).newproperty(:file) do
        desc 'The database file to use.'
      end
    SOURCE
    end

    it 'generates a doc string for a property' do
      expect(spec_subject.size).to eq(1)
      object = spec_subject.first
      expect(object.properties.size).to eq(1)
      expect(object.properties[0].name).to eq('file')
      expect(object.properties[0].docstring).to eq('The database file to use.')
    end
  end

  describe 'parsing source with newparam' do
    let(:source) do
      <<~SOURCE
      Puppet::Type.newtype(:database) do
        desc 'database'
      end
      Puppet::Type.type(:database).newparam(:name) do
        desc 'The database server name.'
      end
    SOURCE
    end

    it 'generates a doc string for a parameter that is also a namevar' do
      expect(spec_subject.size).to eq(1)
      object = spec_subject.first
      expect(object.parameters.size).to eq(1)
      expect(object.parameters[0].name).to eq('name')
      expect(object.parameters[0].docstring).to eq('The database server name.')
      expect(object.parameters[0].isnamevar).to eq(true)
    end
  end

  describe 'parsing source with ensurable' do
    let(:source) do
      <<~SOURCE
      Puppet::Type.newtype(:database) do
        desc 'database'
      end
      Puppet::Type.type(:database).ensurable do
        desc 'What state the database should be in.'
      end
    SOURCE
    end

    it 'generates a doc string for an ensurable' do
      expect(spec_subject.size).to eq(1)
      object = spec_subject.first
      expect(object.properties.size).to eq(1)
      expect(object.properties[0].name).to eq('ensure')
      expect(object.properties[0].docstring).to eq('What state the database should be in.')
    end
  end
end
