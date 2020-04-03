# An example Puppet Data Type in Ruby.
#
# @param param1 A variant parameter.
# @param param2 Optional String parameter.
# @!method func1(param1, param2)
#   func1 documentation
#   @param [String] param1 param1 documentation
#   @param [Integer] param2 param2 documentation
#   @return [Optional[String]]
Puppet::DataTypes.create_type('UnitDataType') do
  interface <<-PUPPET
    attributes => {
      param1 => Variant[Numeric, String[1,2]],
      param2 => { type => Optional[String[1]], value => "param2" }
    },
    functions => {
      func1 => Callable[[String, Integer], Optional[String]]
    }
    PUPPET
end
