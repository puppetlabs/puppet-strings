# @param [Float] ident identification
class foo( String $ident = "Bob" , Integer $age = 10, )
{
   notify {'$ident':}
   notify {'$age':}
}

