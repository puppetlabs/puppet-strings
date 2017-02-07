require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'

# Add our own tasks
require 'puppet-strings/tasks'

PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.ignore_paths = %w(acceptance/**/*.pp spec/**/*.pp pkg/**/*.pp)

desc 'Validate Ruby source files and ERB templates.'
task :validate do
  Dir['spec/**/*.rb','lib/**/*.rb'].each do |ruby_file|
    sh "ruby -c #{ruby_file}" unless ruby_file =~ /spec\/fixtures/
  end
  Dir['lib/puppet-strings/yard/templates/**/*.erb'].each do |template|
    sh "erb -P -x -T '-' #{template} | ruby -c"
  end
end

task :acceptance do
  require 'beaker-hostgenerator'

  install_type = 'aio'
  target = ENV['platform']
  if ! target
    STDERR.puts 'TEST_TARGET environment variable is not set'
    STDERR.puts 'setting to default value of "centos7-64ma".'
    target = "centos7-64ma{type=#{install_type}}"
  end

  unless target =~ /type=/
    puts "INFO: adding 'type=#{install_type}' to host config"
    target += "{type=#{install_type}}"
  end

  cli = BeakerHostGenerator::CLI.new([target])
  nodeset_dir = 'spec/acceptance/nodesets'
  nodeset = "#{nodeset_dir}/#{target}.yml"
  FileUtils.mkdir_p(nodeset_dir)
  File.open(nodeset, 'w') do |fh|
    fh.print(cli.execute)
  end
  puts "nodeset file:"
  puts nodeset
  sh 'gem build puppet-strings.gemspec'
  sh 'puppet module build spec/fixtures/acceptance/modules/test'
  if ENV['BEAKER_keyfile']
    sh "BEAKER_set=#{target} rspec spec/acceptance/*.rb"
  else
    sh "BEAKER_keyfile=$HOME/.ssh/id_rsa-acceptance BEAKER_set=#{target} rspec spec/acceptance/*.rb"
  end
end

task(:rubocop) do
  require 'rubocop'
  cli = RuboCop::CLI.new
  cli.run(%w(-D -f s))
end
