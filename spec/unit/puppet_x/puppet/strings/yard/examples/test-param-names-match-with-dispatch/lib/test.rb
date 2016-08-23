# @param [Integer] num_a the first number to be compared
# @param num_b [Integer] the second number to be compared
Puppet::Functions.create_function(:max) do
  dispatch max_1 do
    param 'Integer', :num_a
    param 'Integer', :num_b
  end
  def max_1(num_a, num_b)
    num_a >= num_b ? num_a : num_b
  end
end
