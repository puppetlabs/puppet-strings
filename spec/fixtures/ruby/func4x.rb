# An example 4.x function.
#
# @example Calling the function
#   $result = func4x(1, 'foo')
#
# @example Calling the function with all args
#   $result = func4x(1, 'foo', ['bar'])
Puppet::Functions.create_function(:func4x) do
  # An overview for the first overload.
  # @raise SomeError this is some error
  # @param param1 The first parameter.
  # @param param2 The second parameter.
  # @option param2 [String] :option an option
  # @option param2 [String] :option2 another option
  # @param param3 The third parameter.
  # @param param4 The fourth parameter.
  # @enum param4 :one Option one.
  # @enum param4 :two Option two.
  # @return Returns nothing.
  # @example Calling the function foo
  #   $result = func4x(1, 'foooo')
  #
  dispatch :foo do
    param          'Integer',       :param1
    param          'Any',           :param2
    optional_param 'Array[String]', :param3
    optional_param 'Enum[one, two]', :param4
    return_type 'Undef'
  end

  # An overview for the second overload.
  # @param param The first parameter.
  # @param block The block parameter.
  # @return Returns a string.
  # @example Calling the function bar
  #   $result = func4x(1, 'bar', ['foo'])
  dispatch :other do
    param 'Boolean', :param
    block_param
    return_type 'String'
  end
end
