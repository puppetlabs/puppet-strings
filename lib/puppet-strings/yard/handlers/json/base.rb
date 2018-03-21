class PuppetStrings::Yard::Handlers::JSON::Base < YARD::Handlers::Base
  def self.handles?(statement)
    handlers.any? {|handler| statement.is_a?(handler)}
  end
end
