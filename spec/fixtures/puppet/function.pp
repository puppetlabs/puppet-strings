# A simple Puppet function.
# @param param1 First param.
# @param param2 Second param.
# @param param3 Third param.
# @option param3 [Array] :param3opt Something about this option
# @param param4 Fourth param.
# @enum param4 :yes Yes option.
# @enum param4 :no No option.
# @raise SomeError this is some error
# @return [Undef] Returns nothing.
# @example Test
#   $result = func(1, 2)
function func(Integer $param1, $param2, String $param3 = hi, Enum['yes', 'no'] $param4 = 'yes') {
}
