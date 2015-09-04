class YARD::CodeObjects::MethodObject

  # Override to_s and to_json methods in Yard's MethodObject so that they
  # return output formatted as I like for puppet 3x and 4x methods.
  def to_s
    if self[:puppet_4x_function] || self[:puppet_3x_function]
      name.to_s
    else
      super
    end
  end

  def to_json(*a)
    if self[:puppet_4x_function]
      {
        "name"                => @name,
        "file"                => file,
        "line"                => line,
        "puppet_version"      => 4,
        "docstring"           => Puppet::Util::Docs.scrub(@docstring),
        "documented_params"   => @parameters.map do |tuple|
          {
            "name" => tuple[0],
            "type" => tuple[1],
          }
        end,
       "signatures"       => @type_info.map do |signature|
          signature.map do |key, value|
            {
              "name" => key,
              "type" => value,
            }
          end
        end,
      }.to_json(*a)
    elsif self[:puppet_3x_function]
      {
        "name"                => @name,
        "file"                => file,
        "line"                => line,
        "puppet_version"      => 3,
        "docstring"           => Puppet::Util::Docs.scrub(@docstring),
        "documented_params"   => @parameters.map do |tuple|
          {
            "name" => tuple[0],
            "type" => tuple[1],
          }
        end,
      }.to_json(*a)
    else
      super
    end
  end


end
