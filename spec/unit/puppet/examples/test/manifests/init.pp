class test (
  $package_name = $test::params::package_name,
  $service_name = $test::params::service_name,
) inherits test::params {

  # validate parameters here

  class { 'test::install': } ->
  class { 'test::config': } ~>
  class { 'test::service': } ->
  Class['test']
}
