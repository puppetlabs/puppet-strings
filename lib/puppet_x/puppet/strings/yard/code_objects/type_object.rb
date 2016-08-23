class PuppetX::Puppet::Strings::YARD::CodeObjects::TypeObject < PuppetX::Puppet::Strings::YARD::CodeObjects::PuppetNamespaceObject
  # A list of parameters attached to this class.
  # @return [Array<Array(String, String)>]
  attr_accessor :parameters

  def to_json(*a)
    {
      "name"             => @name,
      "file"             => file,
      "line"             => line,
      "docstring"        => Puppet::Util::Docs.scrub(@docstring),
      "parameters"       => @parameter_details.map do |obj|
        {
          "allowed_values" => obj[:allowed_values] ? obj[:allowed_values].flatten : [],
          "default"        => obj[:default],
          "docstring"      => Puppet::Util::Docs.scrub(obj[:desc] || ''),
          "namevar"        => obj[:namevar],
          "name"           => obj[:name],
        }
      end,
      "examples"              => self.tags.map do |tag|
          tag.text if tag.tag_name == 'example'
      end.compact,
      "properties"         => @property_details.map do |obj|
        {
          "allowed_values" => obj[:allowed_values] ? obj[:allowed_values].flatten : [],
          "default"        => obj[:default],
          "docstring"      => Puppet::Util::Docs.scrub(obj[:desc] || ''),
          "name"           => obj[:name],
        }
      end,
      "features"         => @features.map do |obj|
        {
          "docstring" => Puppet::Util::Docs.scrub(obj[:desc] || ''),
          "methods"   => obj[:methods],
          "name"      => obj[:name],
        }
      end,
    }.to_json(*a)
  end

end
