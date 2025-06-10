# Class: test
#
#   This class exists to serve as fixture data for testing the puppet strings face
#
# @example Basic usage
#   class { "test": }
#
# @param package_name The name of the package
# @param service_name The name of the service
# @param myenum
# @enum myenum a Option A
# @enum myenum b Option B
class test (
  $package_name = $test::params::package_name,
  $service_name = $test::params::service_name,
  Enum['a', 'b'] $myenum = 'a',

) inherits test::params {

  # validate parameters here

  class { 'test::install': } ->
  class { 'test::config': } ~>
  class { 'test::service': } ->
  Class['test']

  File {
    owner => 'user',
    path => 'some/file/path',
  }
}
