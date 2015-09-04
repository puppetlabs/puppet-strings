require 'json'

class PuppetX::PuppetLabs::Strings::YARD::CodeObjects::DefinedTypeObject < PuppetX::PuppetLabs::Strings::YARD::CodeObjects::PuppetNamespaceObject
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
    }.to_json(*a)
  end
end
