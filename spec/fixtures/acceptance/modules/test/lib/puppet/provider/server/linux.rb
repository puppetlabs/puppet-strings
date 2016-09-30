Puppet::Type.type(:database).provide :linux do
  confine 'osfamily' => 'linux'
  defaultfor 'osfamily' => 'linux'
  commands :database => '/usr/bin/database'

  desc 'The database provider on Linux.'

  # ...
end
