# Monkey patch URL decoding in object displays. Usually :: is interpreted as a
# namespace, but this is disabled in our base object, and so instead gets
# URL-encoded.
require 'yard/server/commands/display_object_command'
class YARD::Server::Commands::DisplayObjectCommand
  private
  alias_method :object_path_yard, :object_path
  def object_path
    object_path_yard.gsub('_3A', ':')
  end
end
