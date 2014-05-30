require 'yard'

# TODO: As far as I can tell, monkeypatching is the officially recommended way
# to extend these tools to cover custom usecases. Follow up on the YARD mailing
# list or IRC to see if there is a better way.

class YARD::CLI::Yardoc
  def all_objects
    YARD::Registry.all(:root, :module, :class, :hostclass, :definedtype)
  end
end

class YARD::CLI::Stats
  def stats_for_hostclasses
    output 'Puppet Classes', *type_statistics(:hostclass)
  end

  def stats_for_definedtypes
    output 'Puppet Types', *type_statistics(:definedtype)
  end
end
