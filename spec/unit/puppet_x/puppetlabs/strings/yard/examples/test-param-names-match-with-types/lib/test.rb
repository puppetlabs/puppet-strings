# @param num_a [Integer[1,2]] the first number to be compared
# @param num_b [Integer[1,2]] the second number to be compared
Puppet::Functions.create_function(:max)do
  def max(num_a, num_b)
    num_a >= num_b ? num_a : num_b
  end
end
