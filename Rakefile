require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'

# Add our own tasks
require 'puppet-strings/tasks'

PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.ignore_paths = ["spec/**/*.pp", "pkg/**/*.pp"]

desc "Validate manifests, templates, and ruby files"
task :validate do
  Dir['manifests/**/*.pp'].each do |manifest|
    sh "puppet parser validate --noop #{manifest}"
  end
  Dir['spec/**/*.rb','lib/**/*.rb'].each do |ruby_file|
    sh "ruby -c #{ruby_file}" unless ruby_file =~ /spec\/fixtures/
  end
  Dir['templates/**/*.erb'].each do |template|
    sh "erb -P -x -T '-' #{template} | ruby -c"
  end
end

task :acceptance do
  require 'beaker-hostgenerator'

  target = ENV['platform']
  if ! target
    STDERR.puts 'TEST_TARGET environment variable is not set'
    STDERR.puts 'setting to default value of "centos7-64ma."'
    target = 'centos7-64ma.'
  end

  cli = BeakerHostGenerator::CLI.new([target])
  nodeset_dir = "spec/acceptance/nodesets"
  nodeset = "#{nodeset_dir}/#{target}.yml"
  FileUtils.mkdir_p(nodeset_dir)
  File.open(nodeset, 'w') do |fh|
    fh.print(cli.execute)
  end
  puts nodeset
  sh "gem build puppet-strings.gemspec"
  sh "puppet module build spec/unit/puppet/examples/test"
  sh "BEAKER_set=#{ENV["platform"]} rspec spec/acceptance/*.rb"
end

task(:rubocop) do
  require 'rubocop'
  cli = RuboCop::CLI.new
  cli.run(%w(-D -f s))
end
