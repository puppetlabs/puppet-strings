require 'spec_helper'
require 'puppet-strings/yard'

describe PuppetStrings::Yard::Handlers::Ruby::TypeHandler do
  subject {
    YARD::Parser::SourceParser.parse_string(source, :ruby)
    YARD::Registry.all(:puppet_type)
  }

  describe 'parsing source without a type definition' do
    let(:source) { 'puts "hi"' }

    it 'no types should be in the registry' do
      expect(subject.empty?).to eq(true)
    end
  end

  describe 'parsing a type with a missing description' do
    let(:source) { <<-SOURCE
Puppet::Type.newtype(:database) do
end
SOURCE
    }

    it 'should log a warning' do
      expect{ subject }.to output(/\[warn\]: Missing a description for Puppet resource type 'database' at \(stdin\):1\./).to_stdout_from_any_process
    end
  end

  describe 'parsing a type definition' do
    let(:source) { <<-SOURCE
Puppet::Type.newtype(:database) do
  desc 'An example database server resource type.'
  feature :encryption, 'The provider supports encryption.', methods: [:encrypt]
  ensurable do
    desc 'What state the database should be in.'
    defaultvalues
    aliasvalue(:up, :present)
    aliasvalue(:down, :absent)
    defaultto :up
  end

  newparam(:address) do
    isnamevar
    desc 'The database server name.'
  end

  newparam(:encryption_key, required_features: :encryption) do
    desc 'The encryption key to use.'
  end

  newparam(:encrypt, :parent => Puppet::Parameter::Boolean) do
    desc 'Whether or not to encrypt the database.'
    defaultto false
  end

  newproperty(:file) do
    desc 'The database file to use.'
  end

  newproperty(:log_level) do
    desc 'The log level to use.'
    newvalue(:debug)
    newvalue(:warn)
    newvalue(:error)
    defaultto 'warn'
  end
end
SOURCE
    }

    it 'should register a type object' do
      expect(subject.size).to eq(1)
      object = subject.first
      expect(object).to be_a(PuppetStrings::Yard::CodeObjects::Type)
      expect(object.namespace).to eq(PuppetStrings::Yard::CodeObjects::Types.instance)
      expect(object.name).to eq(:database)
      expect(object.docstring).to eq('An example database server resource type.')
      expect(object.docstring.tags.size).to eq(1)
      tags = object.docstring.tags(:api)
      expect(tags.size).to eq(1)
      expect(tags[0].text).to eq('public')
      expect(object.properties.size).to eq(3)
      expect(object.properties[0].name).to eq('ensure')
      expect(object.properties[0].docstring).to eq('What state the database should be in.')
      expect(object.properties[0].isnamevar).to eq(false)
      expect(object.properties[0].default).to eq('up')
      expect(object.properties[0].values).to eq(%w(present absent up down))
      expect(object.properties[0].aliases).to eq({ 'down' => 'absent', 'up' => 'present' })
      expect(object.properties[1].name).to eq('file')
      expect(object.properties[1].docstring).to eq('The database file to use.')
      expect(object.properties[1].isnamevar).to eq(false)
      expect(object.properties[1].default).to be_nil
      expect(object.properties[1].values).to eq([])
      expect(object.properties[1].aliases).to eq({})
      expect(object.properties[2].name).to eq('log_level')
      expect(object.properties[2].docstring).to eq('The log level to use.')
      expect(object.properties[2].isnamevar).to eq(false)
      expect(object.properties[2].default).to eq('warn')
      expect(object.properties[2].values).to eq(%w(debug warn error))
      expect(object.properties[2].aliases).to eq({})
      expect(object.parameters.size).to eq(3)
      expect(object.parameters[0].name).to eq('address')
      expect(object.parameters[0].docstring).to eq('The database server name.')
      expect(object.parameters[0].isnamevar).to eq(true)
      expect(object.parameters[0].default).to be_nil
      expect(object.parameters[0].values).to eq([])
      expect(object.parameters[0].aliases).to eq({})
      expect(object.parameters[1].name).to eq('encryption_key')
      expect(object.parameters[1].docstring).to eq('The encryption key to use.')
      expect(object.parameters[1].isnamevar).to eq(false)
      expect(object.parameters[1].default).to be_nil
      expect(object.parameters[1].values).to eq([])
      expect(object.parameters[1].aliases).to eq({})
      expect(object.parameters[2].name).to eq('encrypt')
      expect(object.parameters[2].docstring).to eq('Whether or not to encrypt the database.')
      expect(object.parameters[2].isnamevar).to eq(false)
      expect(object.parameters[2].default).to eq('false')
      expect(object.parameters[2].values).to eq(%w(true false yes no))
      expect(object.parameters[2].aliases).to eq({})
      expect(object.features.size).to eq(1)
      expect(object.features[0].name).to eq('encryption')
      expect(object.features[0].docstring).to eq('The provider supports encryption.')
    end
  end
end
