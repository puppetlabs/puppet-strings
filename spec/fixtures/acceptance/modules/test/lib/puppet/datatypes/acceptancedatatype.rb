# An example Acceptance Puppet Data Type in Ruby.
#
# @param param1 A variant parameter called param1.
# @param param2 Optional String parameter called param2.
# @method func1(param1, param2)
#   func1 documentation
#   @param [String] param1 param1 func1 documentation
#   @param [Integer] param2 param2 func1 documentation
#   @return [Optional[String]]
Puppet::DataTypes.create_type('AcceptanceDataType') do
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
