require 'yard'

# TODO: As far as I can tell, monkeypatching is the officially recommended way
# to extend these tools to cover custom usecases. Follow up on the YARD mailing
# list or IRC to see if there is a better way.

class YARD::CLI::Yardoc
  def all_objects
    YARD::Registry.all(:root, :module, :class, :puppetnamespace, :hostclass, :definedtype)
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
