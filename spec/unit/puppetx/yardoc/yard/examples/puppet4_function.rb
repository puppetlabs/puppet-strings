require 'puppet'

Puppet::Functions.create_function(:puppet4_function) do
  def puppet4_function(x,y)
    x >= y ? x : y
  end
end
