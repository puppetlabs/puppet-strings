require 'bundler/gem_tasks'
#require 'puppetlabs_spec_helper/rake_tasks'
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
  abs = if ENV['BEAKER_ABS'] then 'abs' else 'vmpooler' end
  if ! target
    STDERR.puts 'TEST_TARGET environment variable is not set'
    STDERR.puts 'setting to default value of "centos7-64ma".'
    target = "centos7-64ma{type=#{install_type}}"
  end

  unless target =~ /type=/
    puts "INFO: adding 'type=#{install_type}' to host config"
    target += "{type=#{install_type}}"
  end

  cli = BeakerHostGenerator::CLI.new([target, '--hypervisor', abs])
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

#### CHANGELOG ####
begin
  require 'github_changelog_generator/task'
  GitHubChangelogGenerator::RakeTask.new :changelog do |config|
    require 'puppet-strings/version'
    config.future_release = "v#{PuppetStrings::VERSION}"
    config.header = "# Changelog\n\n" \
      "All significant changes to this repo will be summarized in this file.\n"
    config.configure_sections = {
          added: {
            prefix: "Added",
            labels: ["enhancement"]
          },
          fixed: {
            prefix: "Fixed",
            labels: ["bugfix"]
          },
          breaking: {
            prefix: "Changed",
            labels: ["backwards-incompatible"]
          }
        }
    config.exclude_labels = ['maintenance']
    config.user = 'puppetlabs'
    config.project = 'puppet-strings'
  end
rescue LoadError
  desc 'Install github_changelog_generator to get access to automatic changelog generation'
  task :changelog do
    raise 'Install github_changelog_generator to get access to automatic changelog generation'
  end
end
