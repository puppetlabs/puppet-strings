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

  describe 'parsing a type with an invalid docstring assignment' do
    let(:source) { <<-SOURCE
Puppet::Type.newtype(:database) do
  @doc = 123
end
    SOURCE
    }

    it 'should log an error' do
      expect { subject }.to output(/Failed to parse docstring/).to_stdout_from_any_process
    end
  end

  describe 'parsing a type with a valid docstring assignment' do
    let(:source) { <<-SOURCE
Puppet::Type.newtype(:database) do
  @doc = 'An example database server resource type.'
end
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
Puppet::Type.newtype(:database) do
  test = 'hello world!'
  desc %Q{This is a multi-line
  doc in %Q with #{test}}
end
    SOURCE
    }

    it 'should strip the `%Q{}` and render the interpolation expression literally' do
      expect(subject.size).to eq(1)
      object = subject.first
      expect(object.docstring).to eq("This is a multi-line\ndoc in %Q with \#{test}")
    end
  end

  describe 'parsing a type with a param with arguments' do
    let(:source) { <<-SOURCE
Puppet::Type.newtype(:database) do
  feature :encryption, 'The provider supports encryption.', methods: [:encrypt]

  newparam(:encryption_key, :parent => Puppet::Parameter::Boolean, required_features: :encryption) do
    desc 'The encryption key to use.'
    defaultto false
  end
end
    SOURCE
    }

    it 'should correctly detect the required_feature' do
      expect(subject.size).to eq(1)
      object = subject.first
      expect(object.parameters[0].required_features).to eq('encryption')
    end

    it 'should correctly detect a boolean parent' do
      expect(subject.size).to eq(1)
      object = subject.first
      expect(object.parameters[0].default).to eq('false')
    end
  end

  describe 'parsing a type definition' do
    let(:source) { <<-SOURCE
# @!puppet.type.param [value1, value2] dynamic_param Documentation for a dynamic parameter.
# @!puppet.type.property [foo, bar] dynamic_prop Documentation for a dynamic property.
Puppet::Type.newtype(:database) do
  desc 'An example database server resource type.'
  feature :encryption, 'The provider supports encryption.', methods: [:encrypt]

  feature :magic,
    'The feature docstring should have
    whitespace and newlines stripped out.'

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

  newparam(:backup) do
      desc 'How often to backup the database.'
      defaultto :never
      newvalues(:daily, :monthly, :never)
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
      expect(object.properties.size).to eq(4)
      expect(object.properties[0].name).to eq('dynamic_prop')
      expect(object.properties[0].docstring).to eq('Documentation for a dynamic property.')
      expect(object.properties[0].isnamevar).to eq(false)
      expect(object.properties[0].values).to eq(%w(foo bar))
      expect(object.properties[1].name).to eq('ensure')
      expect(object.properties[1].docstring).to eq('What state the database should be in.')
      expect(object.properties[1].isnamevar).to eq(false)
      expect(object.properties[1].default).to eq('up')
      expect(object.properties[1].values).to eq(%w(present absent up down))
      expect(object.properties[1].aliases).to eq({ 'down' => 'absent', 'up' => 'present' })
      expect(object.properties[2].name).to eq('file')
      expect(object.properties[2].docstring).to eq('The database file to use.')
      expect(object.properties[2].isnamevar).to eq(false)
      expect(object.properties[2].default).to be_nil
      expect(object.properties[2].values).to eq([])
      expect(object.properties[2].aliases).to eq({})
      expect(object.properties[3].name).to eq('log_level')
      expect(object.properties[3].docstring).to eq('The log level to use.')
      expect(object.properties[3].isnamevar).to eq(false)
      expect(object.properties[3].default).to eq('warn')
      expect(object.properties[3].values).to eq(%w(debug warn error))
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
      expect(object.parameters[1].values).to eq([])
      expect(object.parameters[1].aliases).to eq({})
      expect(object.parameters[2].name).to eq('encryption_key')
      expect(object.parameters[2].docstring).to eq('The encryption key to use.')
      expect(object.parameters[2].isnamevar).to eq(false)
      expect(object.parameters[2].default).to be_nil
      expect(object.parameters[2].values).to eq([])
      expect(object.parameters[2].aliases).to eq({})
      expect(object.parameters[3].name).to eq('encrypt')
      expect(object.parameters[3].docstring).to eq('Whether or not to encrypt the database.')
      expect(object.parameters[3].isnamevar).to eq(false)
      expect(object.parameters[3].default).to eq('false')
      expect(object.parameters[3].values).to eq(%w(true false yes no))
      expect(object.parameters[3].aliases).to eq({})
      expect(object.parameters[4].name).to eq('backup')
      expect(object.parameters[4].docstring).to eq('How often to backup the database.')
      expect(object.parameters[4].isnamevar).to eq(false)
      expect(object.parameters[4].default).to eq('never')
      expect(object.parameters[4].values).to eq(%w(daily monthly never))
      expect(object.features.size).to eq(2)
      expect(object.features[0].name).to eq('encryption')
      expect(object.features[0].docstring).to eq('The provider supports encryption.')
      expect(object.features[1].name).to eq('magic')
      expect(object.features[1].docstring).to eq('The feature docstring should have whitespace and newlines stripped out.')
    end
  end

  describe 'parsing a valid type with string based name' do
    let(:source) { <<-SOURCE
Puppet::Type.newtype(:'database') do
  desc 'An example database server resource type.'
  ensurable
end
    SOURCE
    }

    it 'should register a type object with default ensure values' do
      expect(subject.size).to eq(1)
      object = subject.first
      expect(object.name).to eq(:database)
    end
  end

  describe 'parsing an ensurable type with default ensure values' do
    let(:source) { <<-SOURCE
Puppet::Type.newtype(:database) do
  desc 'An example database server resource type.'
  ensurable
end
    SOURCE
    }

    it 'should register a type object with default ensure values' do
      expect(subject.size).to eq(1)
      object = subject.first
      expect(object.properties[0].name).to eq('ensure')
      expect(object.properties[0].docstring).to eq('The basic property that the resource should be in.')
      expect(object.properties[0].default).to eq('present')
      expect(object.properties[0].values).to eq(%w(present absent))
    end
  end

  describe 'parsing a type with a parameter with the name of "name"' do
    let(:source) { <<-SOURCE
Puppet::Type.newtype(:database) do
  desc 'An example database server resource type.'
  newparam(:name) do
    desc 'The database server name.'
  end
end
    SOURCE
    }

    it 'should register a type object with the "name" parameter as the namevar' do
      expect(subject.size).to eq(1)
      object = subject.first
      expect(object.parameters.size).to eq(1)
      expect(object.parameters[0].name).to eq('name')
      expect(object.parameters[0].isnamevar).to eq(true)
    end
  end

  describe 'parsing a type with a summary' do
    context 'when the summary has fewer than 140 characters' do
      let(:source) { <<-SOURCE
Puppet::Type.newtype(:database) do
  @doc = '@summary A short summary.'
end
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
Puppet::Type.newtype(:database) do
  @doc = '@summary A short summary that is WAY TOO LONG. AHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH this is not what a summary is for! It should be fewer than 140 characters!!'
end
      SOURCE
      }

      it 'should log a warning' do
        expect{ subject }.to output(/\[warn\]: The length of the summary for puppet_type 'database' exceeds the recommended limit of 140 characters./).to_stdout_from_any_process
      end
    end
  end
end
