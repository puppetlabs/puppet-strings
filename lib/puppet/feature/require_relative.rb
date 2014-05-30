require 'puppet/util/feature'

# Support require_relative under Ruby 1.8.7.
Puppet.features.add(:require_relative, :libs => ['backports/1.9.1/kernel/require_relative'])
