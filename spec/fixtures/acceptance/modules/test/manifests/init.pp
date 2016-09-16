# Class: test
#
#   This class exists to serve as fixture data for testing the puppet strings face
#
# @example
#   class { "test": }
#
# @param package_name The name of the package
# @param service_name The name of the service
class test (
  $package_name = $test::params::package_name,
  $service_name = $test::params::service_name,

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
