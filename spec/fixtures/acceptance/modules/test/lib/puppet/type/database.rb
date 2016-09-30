# @!puppet.type.param [value1, value2, value3] my_param Documentation for a dynamic parameter.
# @!puppet.type.property [foo, bar, baz] my_prop Documentation for a dynamic property.
Puppet::Type.newtype(:database) do
  desc 'An example server resource type.'
  feature :encryption, 'The provider supports encryption.', methods: [:encrypt]

  newparam(:address) do
    isnamevar
    desc 'The database server name.'
  end

  newproperty(:file) do
    desc 'The database file to use.'
  end
end
