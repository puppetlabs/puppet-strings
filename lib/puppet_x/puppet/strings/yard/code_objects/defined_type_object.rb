require 'json'

class PuppetX::Puppet::Strings::YARD::CodeObjects::DefinedTypeObject < PuppetX::Puppet::Strings::YARD::CodeObjects::PuppetNamespaceObject
  # A list of parameters attached to this class.
  # @return [Array<Array(String, String)>]
  attr_accessor :parameters
  attr_accessor :type_info

  def to_s
    name.to_s
  end

  def to_json(*a)
    {
      "name"             => @name,
      "file"             => file,
      "line"             => line,
      "parameters"       => Hash[@parameters],
      "docstring"        => Puppet::Util::Docs.scrub(@docstring),
      "signatures"       => @type_info.map do |signature|
        signature.map do |key, value|
          {
            "name" => key,
            "type" => value,
          }
        end
      end,
      "examples"              => self.tags.map do |tag|
          tag.text if tag.tag_name == 'example'
      end.compact,
    }.to_json(*a)
  end
end
