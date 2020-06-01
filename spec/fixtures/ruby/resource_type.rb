Puppet::Type.newtype(:database) do
  desc <<-DESC
An example database server type.
@option opts :foo bar
@enum ensure :up Upstate
@enum ensure :down Downstate
@raise SomeError
@example here's an example
 database { 'foo':
   address => 'qux.baz.bar',
 }
DESC
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

  newcheck(:exists) do
    desc 'Check to see if the database already exists'
  end
end
