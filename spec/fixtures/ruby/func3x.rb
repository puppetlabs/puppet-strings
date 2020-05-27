# An example 3.x function
Puppet::Parser::Functions.newfunction(:func3x, doc: <<-DOC
 Documentation for an example 3.x function.
 @param param1 [String] The first parameter.
 @param param2 [Integer] The second parameter.
 @return [Undef]
 @example Calling the function.
   func3x('hi', 10)
 DOC
 ) do |*args|
   #...
end
