# @param not_a_param [Integer] the first number to be compared
# @param also_not_a_param [Integer] the second number to be compared
Puppet::Functions.create_function(:max) do
  dispatch max_1 do
    param 'Integer[1,2]', :num_a
    param 'Integer', :num_b
  end
  dispatch max_2 {
    param 'String', :num_c
    param 'String[1,2]', :num_d
  }
  def max_1(num_a, num_b)
    num_a >= num_b ? num_a : num_b
  end
  def max_2(num_a, num_b)
    num_a >= num_b ? num_a : num_b
  end
end
