# An example Puppet Data Type in Ruby.
#
# @param param1 A variant parameter.
# @param param2 Optional String parameter.
Puppet::DataTypes.create_type('UnitDataType') do
  interface <<-PUPPET
    attributes => {
      param1 => Variant[Numeric, String[1,2]],
      param2 => { type => Optional[String[1]], value => "param2" }
    }
    PUPPET
end
