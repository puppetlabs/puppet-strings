# An example 4.x function with only one signature.
Puppet::Functions.create_function(:func4x_1) do
  # @param param1 The first parameter.
  # @return [Undef] Returns nothing.
  dispatch :foobarbaz do
    param          'Integer',       :param1
  end
end

