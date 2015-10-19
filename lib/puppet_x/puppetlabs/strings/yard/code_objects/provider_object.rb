class PuppetX::PuppetLabs::Strings::YARD::CodeObjects::ProviderObject < PuppetX::PuppetLabs::Strings::YARD::CodeObjects::PuppetNamespaceObject
  # A list of parameters attached to this class.
  # @return [Array<Array(String, String)>]
  attr_accessor :parameters

  def to_json(*a)
    {
      "name"             => @name,
      "type_name"        => @type_name,
      "file"             => file,
      "line"             => line,
      "docstring"        => Puppet::Util::Docs.scrub(@docstring),
      "commands"         => @commands,
      "confines"         => @confines,
      "defaults"         => @defaults,
      "features"         => @features,
      "examples"              => self.tags.map do |tag|
          tag.text if tag.tag_name == 'example'
      end.compact,
    }.to_json(*a)
  end


end
