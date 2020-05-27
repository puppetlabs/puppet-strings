# An overview for a simple class.
# @summary A simple class.
# @todo Do a thing
# @note some note
# @since 1.0.0
# @see www.puppet.com
# @example This is an example
#  class { 'klass':
#    param1 => 1,
#    param3 => 'foo',
#  }
# @example This is another example
#  class { 'klass':
#    param1 => 1,
#    param3 => 'foo',
#  }
# @raise SomeError
# @param param1 First param.
# @param param2 Second param.
# @option param2 [String] :opt1 something about opt1
# @option param2 [Hash] :opt2 a hash of stuff
# @param param3 Third param.
# @param param4 Fourth param.
# @enum param4 :one One option
# @enum param4 :two Second option
#
class klass (
  Integer $param1 = 1,
  $param2 = undef,
  String $param3 = 'hi',
  Enum['one', 'two'] $param4 = 'two',
) inherits foo::bar {
}

# Overview for class noparams
# @api private
class noparams () {}

# An overview for a simple defined type.
# @summary A simple defined type.
# @since 1.1.0
# @see www.puppet.com
# @example Here's an example of this type:
#  klass::dt { 'foo':
#    param1 => 33,
#    param4 => false,
#  }
# @return shouldn't return squat
# @raise SomeError
# @param param1 First param.
# @param param2 Second param.
# @option param2 [String] :opt1 something about opt1
# @option param2 [Hash] :opt2 a hash of stuff
# @param param3 Third param.
# @param param4 Fourth param.
# @param param5 Fifth param.
# @enum param5 :a Option A
# @enum param5 :b Option B
define klass::dt (
  Integer $param1 = 44,
  $param2,
  String $param3 = 'hi',
  Boolean $param4 = true,
  Enum['a', 'b'] $param5 = 'a'
) {
}
