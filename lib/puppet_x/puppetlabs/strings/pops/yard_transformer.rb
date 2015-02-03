# Loosely based on the TreeDumper classes in Pops::Model. The responsibility of
# this class is to walk a Pops::Model and output objects that can be consumed
# by YARD handlers.
#
# @note Currently, this class only extracts node, host class and type
#   definitions.
class PuppetX::PuppetLabs::Strings::Pops::YARDTransformer
  def initialize
    @transform_visitor = Puppet::Pops::Visitor.new(self, 'transform')
  end

  def transform(o)
    @transform_visitor.visit(o)
  end

  private

  def transform_Factory(o)
    transform(o.current)
  end

  def transform_Program(o)
    o.definitions.map{|d| transform(d)}
  end

  # Extract comments from type definitions and class definitions. Wrap them
  # into YARDStatement objects that provide an interface for YARD handlers.
  def transform_NamedDefinition(o)
    obj = PuppetX::PuppetLabs::Strings::Pops::YARDStatement.new(o)
    obj.parameters = o.parameters.map do |p|
      param_tuple = [transform(p)]
      param_tuple << ( p.value.nil? ? nil : transform(p.value) )
    end

    obj
  end

  # Catch-all visitor.
  def transform_Positioned(o)
    PuppetX::PuppetLabs::Strings::Pops::YARDStatement.new(o)
  end

  # nil in... nil out!
  def transform_NilClass(o)
    nil
  end
end
