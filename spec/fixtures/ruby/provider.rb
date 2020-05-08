Puppet::Type.type(:database).provide :linux do
  desc 'An example provider on Linux.'
  confine kernel: 'Linux'
  confine osfamily: 'RedHat'
  defaultfor :kernel => 'Linux'
  defaultfor :osfamily => 'RedHat', :operatingsystemmajrelease => '7'
  has_feature :implements_some_feature
  has_feature :some_other_feature
  commands foo: '/usr/bin/foo'
end

