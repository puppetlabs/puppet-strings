require 'spec_helper'
require 'puppet-strings/yard'

describe PuppetStrings::Yard::Handlers::Ruby::RsapiHandler do
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
Puppet::ResourceApi.register_type(
  name: 'database'
)
    SOURCE
    }

    it 'should log a warning' do
      expect{ subject }.to output(/\[warn\]: Missing a description for Puppet resource type 'database' at \(stdin\):1\./).to_stdout_from_any_process
    end
  end

  describe 'parsing a type with a valid docstring assignment' do
    let(:source) { <<-SOURCE
Puppet::ResourceApi.register_type(
  name: 'database',
  docs: 'An example database server resource type.',
)
    SOURCE
    }

    it 'should correctly detect the docstring' do
      expect(subject.size).to eq(1)
      object = subject.first
      expect(object.docstring).to eq('An example database server resource type.')
    end
  end

  describe 'parsing a type with a docstring which uses ruby `%Q` notation' do
    let(:source) { <<-'SOURCE'
test = 'hello world!'

Puppet::ResourceApi.register_type(
  name: 'database',
  docs: %Q{This is a multi-line
doc in %Q with #{test}},
)
    SOURCE
    }

    it 'should strip the `%Q{}` and render the interpolation expression literally' do
      expect(subject.size).to eq(1)
      object = subject.first
      expect(object.docstring).to eq("This is a multi-line\ndoc in %Q with \#{test}")
    end
  end

  describe 'parsing a type definition' do
    let(:source) { <<-SOURCE
# @!puppet.type.param [value1, value2] dynamic_param Documentation for a dynamic parameter.
# @!puppet.type.property [foo, bar] dynamic_prop Documentation for a dynamic property.
Puppet::ResourceApi.register_type(
  name: 'database',
  docs: 'An example database server resource type.',
  features: ['remote-resource'],
  attributes: {
    ensure: {
      type: 'Enum[present, absent, up, down]',
      desc: 'What state the database should be in.',
      default: 'up',
    },
    address: {
      type: 'String',
      desc: 'The database server name.',
      behaviour: :namevar,
    },
    encrypt: {
      type: 'Boolean',
      desc: 'Whether or not to encrypt the database.',
      default: false,
      behaviour: :parameter,
    },
    encryption_key: {
      type: 'Optional[String]',
      desc: 'The encryption key to use.',
      behaviour: :parameter,
    },
    backup: {
      type: 'Enum[daily, monthly, never]',
      desc: 'How often to backup the database.',
      default: 'never',
      behaviour: :parameter,
    },
    file: {
      type: 'String',
      desc: 'The database file to use.',
    },
    log_level: {
      type: 'Enum[debug, warn, error]',
      desc: 'The log level to use.',
      default: 'warn',
    },
  },
)
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
      expect(object.properties.map(&:name)).to eq(['dynamic_prop', 'ensure', 'file', 'log_level'])
      expect(object.properties.size).to eq(4)
      expect(object.properties[0].name).to eq('dynamic_prop')
      expect(object.properties[0].docstring).to eq('Documentation for a dynamic property.')
      expect(object.properties[0].isnamevar).to eq(false)
      expect(object.properties[0].values).to eq(%w(foo bar))
      expect(object.properties[1].name).to eq('ensure')
      expect(object.properties[1].docstring).to eq('What state the database should be in.')
      expect(object.properties[1].isnamevar).to eq(false)
      expect(object.properties[1].default).to eq('up')
      expect(object.properties[1].data_type).to eq('Enum[present, absent, up, down]')
      expect(object.properties[1].aliases).to eq({})
      expect(object.properties[2].name).to eq('file')
      expect(object.properties[2].docstring).to eq('The database file to use.')
      expect(object.properties[2].isnamevar).to eq(false)
      expect(object.properties[2].default).to be_nil
      expect(object.properties[2].data_type).to eq('String')
      expect(object.properties[2].aliases).to eq({})
      expect(object.properties[3].name).to eq('log_level')
      expect(object.properties[3].docstring).to eq('The log level to use.')
      expect(object.properties[3].isnamevar).to eq(false)
      expect(object.properties[3].default).to eq('warn')
      expect(object.properties[3].data_type).to eq('Enum[debug, warn, error]')
      expect(object.properties[3].aliases).to eq({})
      expect(object.parameters.size).to eq(5)
      expect(object.parameters[0].name).to eq('dynamic_param')
      expect(object.parameters[0].docstring).to eq('Documentation for a dynamic parameter.')
      expect(object.parameters[0].isnamevar).to eq(false)
      expect(object.parameters[0].values).to eq(%w(value1 value2))
      expect(object.parameters[1].name).to eq('address')
      expect(object.parameters[1].docstring).to eq('The database server name.')
      expect(object.parameters[1].isnamevar).to eq(true)
      expect(object.parameters[1].default).to be_nil
      expect(object.parameters[1].data_type).to eq('String')
      expect(object.parameters[1].aliases).to eq({})
      expect(object.parameters[2].name).to eq('encrypt')
      expect(object.parameters[2].docstring).to eq('Whether or not to encrypt the database.')
      expect(object.parameters[2].isnamevar).to eq(false)
      expect(object.parameters[2].default).to eq(false)
      expect(object.parameters[2].data_type).to eq("Boolean")
      expect(object.parameters[2].aliases).to eq({})
      expect(object.parameters[3].name).to eq('encryption_key')
      expect(object.parameters[3].docstring).to eq('The encryption key to use.')
      expect(object.parameters[3].isnamevar).to eq(false)
      expect(object.parameters[3].default).to be_nil
      expect(object.parameters[3].data_type).to eq("Optional[String]")
      expect(object.parameters[3].aliases).to eq({})
      expect(object.parameters[4].name).to eq('backup')
      expect(object.parameters[4].docstring).to eq('How often to backup the database.')
      expect(object.parameters[4].isnamevar).to eq(false)
      expect(object.parameters[4].default).to eq('never')
      expect(object.parameters[4].data_type).to eq("Enum[daily, monthly, never]")
    end
  end

  describe 'parsing a type with a summary' do
    context 'when the summary has fewer than 140 characters' do
      let(:source) { <<-SOURCE
Puppet::ResourceApi.register_type(
  name: 'database',
  docs: '@summary A short summary.',
)
      SOURCE
      }

      it 'should parse the summary' do
        expect{ subject }.to output('').to_stdout_from_any_process
        expect(subject.size).to eq(1)
        summary = subject.first.tags(:summary)
        expect(summary.first.text).to eq('A short summary.')
      end
    end

    context 'when the summary has more than 140 characters' do
      let(:source) { <<-SOURCE
Puppet::ResourceApi.register_type(
  name: 'database',
  docs: '@summary A short summary that is WAY TOO LONG. AHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH this is not what a summary is for! It should be fewer than 140 characters!!',
)
      SOURCE
      }

      it 'should log a warning' do
        expect{ subject }.to output(/\[warn\]: The length of the summary for puppet_type 'database' exceeds the recommended limit of 140 characters./).to_stdout_from_any_process
      end
    end
  end

  describe 'parsing a type with title_patterns' do
    let(:source) { <<-SOURCE
Puppet::ResourceApi.register_type(
  name: 'database',
  docs: 'An example database server resource type.',
  title_patterns: [
    {
      pattern: %r{(?<name>.*)},
      desc: 'Generic title match',
    }
  ]
)
    SOURCE
    }

    it 'should not emit a warning' do
      expect{ subject }.not_to output(/\[warn\].*unexpected construct regexp_literal/).to_stdout_from_any_process
    end
  end

end
