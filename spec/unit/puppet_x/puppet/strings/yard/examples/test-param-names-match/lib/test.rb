# @param num_a [Integer] the first number to be compared
# @param num_b [Integer] the second number to be compared
Puppet::Functions.create_function(:max)do
  def max(num_a, num_b)
    num_a >= num_b ? num_a : num_b
  end
end
