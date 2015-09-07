# @param not_a_param [Integer] the first number to be compared
# @param also_not_a_param [Integer] the second number to be compared
Puppet::Functions.create_function(:max) do
  def max(num_a, num_b)
    num_a >= num_b ? num_a : num_b
  end
end
