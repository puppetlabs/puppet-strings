require 'yard'
require File.join(File.dirname(__FILE__), './json_registry_store')

# TODO: As far as I can tell, monkeypatching is the officially recommended way
# to extend these tools to cover custom usecases. Follow up on the YARD mailing
# list or IRC to see if there is a better way.

class YARD::CLI::Yardoc
  def all_objects
    YARD::Registry.all(:root, :module, :class, :type, :provider, :puppetnamespace, :hostclass, :definedtype)
  end
end

class YARD::CLI::Stats
  def stats_for_hostclasses
    output 'Puppet Classes', *type_statistics(:hostclass)
  end

  def stats_for_definedtypes
    output 'Puppet Defined Types', *type_statistics(:definedtype)
  end

  def stats_for_puppet_types
    output 'Puppet Types', *type_statistics(:type)
  end

  def stats_for_puppet_provider
    output 'Puppet Providers', *type_statistics(:provider)
  end
end

class YARD::Logger
  def show_progress
    return false if YARD.ruby18? # threading is too ineffective for progress support
    return false if YARD.windows? # windows has poor ANSI support
    return false unless io.tty? # no TTY support on IO
    # Here is the actual monkey patch. A simple fix to an inverted conditional.
    # Without this Pry is unusable for debugging as the progress bar goes
    # craaaaaaaazy.
    return false unless level > INFO # no progress in verbose/debug modes
    @show_progress
  end

  # Redirect Yard command line warnings to a log file called .yardwarns
  # Yard warnings may be irrelevant, spurious, or may not conform with our
  # styling and UX design. They are also printed on stdout by default.
  def warn warning
    f = File.new '.yardwarns', 'a'
    f.write warning
    f.close()
  end
end


# 15:04:42       radens | lsegal: where would you tell yard to use your custom RegistryStore?
# 15:09:54      @lsegal | https://github.com/lsegal/yard/blob/master/lib/yard/registry.rb#L428-L435
# 15:09:54      @lsegal | you would set that attr on Registry
# 15:09:54      @lsegal | it might be worth expanding that API to swap out the store class used
# 15:10:49      @lsegal | specifically
#                       | https://github.com/lsegal/yard/blob/master/lib/yard/registry.rb#L190 and
#                       | replace RegistryStore there with a storage_class attr
module YARD::Registry
  class << self
  def clear
    self.thread_local_store = YARD::JsonRegistryStore.new
  end
  end
end
