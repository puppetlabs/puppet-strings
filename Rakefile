# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'rspec/core/rake_task'
require 'puppetlabs_spec_helper/tasks/fixtures'

begin
  require 'puppet_litmus/rake_tasks'
rescue LoadError
  # Gem not present
end

RSpec::Core::RakeTask.new(:spec) do |t|
  t.exclude_pattern = "spec/acceptance/**/*.rb"
end

task :spec => :spec_clean

# Add our own tasks
require 'puppet-strings/tasks'

PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.ignore_paths = %w(acceptance/**/*.pp spec/**/*.pp pkg/**/*.pp)

desc 'Validate Ruby source files and ERB templates.'
task :validate do
  Dir['spec/**/*.rb','lib/**/*.rb'].each do |ruby_file|
    sh "ruby -c #{ruby_file}" unless /spec\/fixtures/.match?(ruby_file)
  end
  Dir['lib/puppet-strings/yard/templates/**/*.erb'].each do |template|
    sh "erb -P -x -T '-' #{template} | ruby -c"
  end
end

namespace :litmus do
  def install_remote_gem(gem_name, target_nodes, inventory_hash)
    # TODO: Currently this is Linux only
    install_command = "/opt/puppetlabs/puppet/bin/gem install #{gem_name}"
    result = run_command(install_command, target_nodes, config: nil, inventory: inventory_hash)
    if result.is_a?(Array)
      result.each do |node|
        puts "#{node['target']} failed: '#{node['value']}'" if node['status'] != 'success'
      end
    else
      raise "Failed trying to run '#{install_command}' against inventory."
    end
  end

  def install_build_tools(target_nodes, inventory_hash)
    puts 'Installing build tools...'
    install_build_command = "yum -y group install 'Development Tools'"
    result = run_command(install_build_command, target_nodes, config: nil, inventory: inventory_hash)
    if result.is_a?(Array)
      result.each do |node|
        puts "#{node['target']} failed: '#{node['value']}'" if node['status'] != 'success'
      end
    else
      raise "Failed trying to run '#{install_build_command}' against inventory."
    end
  end

  # Install the gem under test and required fixture on a collection of nodes
  #
  # @param :target_node_name [Array] nodes on which to install a puppet module for testing.
  desc 'install_gems - build and install module fixtures'
  task :install_gems, [:target_node_name] do |_task, args|
    inventory_hash = inventory_hash_from_inventory_file
    target_nodes = find_targets(inventory_hash, args[:target_node_name])
    if target_nodes.empty?
      puts 'No targets found'
      exit 0
    end
    require 'bolt_spec/run'
    include BoltSpec::Run

    # Build the gem
    puts 'Building gem...'
    `gem build puppet-strings.gemspec --quiet`
    result = $CHILD_STATUS
    raise "Unable to build the puppet-strings gem. Returned exit code #{result.exitstatus}" unless result.exitstatus.zero?

    # Find the gem build artifact
    gem_tar = Dir.glob('puppet-strings-*.gem').max_by { |f| File.mtime(f) }
    raise "Unable to find package in 'puppet-strings-*.gem'" if gem_tar.nil?

    gem_tar = File.expand_path(gem_tar)

    target_string = if args[:target_node_name].nil?
                      'all'
                    else
                      args[:target_node_name]
                    end
    puts 'Copying gem to targets...'
    upload_file(gem_tar, File.basename(gem_tar), target_string, inventory: inventory_hash)

    install_build_tools(target_nodes, inventory_hash)

    # Install dependent gems
    puts 'Installing yard gem...'
    install_remote_gem('yard', target_nodes, inventory_hash)
    puts 'Installing rgen gem...'
    install_remote_gem('rgen', target_nodes, inventory_hash)
    # Install puppet-strings
    puts 'Installing puppet-strings gem...'
    install_remote_gem(File.basename(gem_tar), target_nodes, inventory_hash)
    puts 'Installed'
  end
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
    config.exclude_labels = ['maintenance','incomplete']
    config.user = 'puppetlabs'
    config.project = 'puppet-strings'
  end
rescue LoadError
  desc 'Install github_changelog_generator to get access to automatic changelog generation'
  task :changelog do
    raise 'Install github_changelog_generator to get access to automatic changelog generation'
  end
end

desc 'Run acceptance tests'
task :acceptance do

  begin
    if ENV['MATRIX_TARGET']
      agent_version = ENV['MATRIX_TARGET'].chomp
    else
      agent_version = 'puppet7'
    end
    
    Rake::Task['litmus:provision'].invoke('docker', 'litmusimage/centos:7')

    Rake::Task['litmus:install_agent'].invoke(agent_version.to_s)

    Rake::Task['litmus:install_modules_from_directory'].invoke('./spec/fixtures/acceptance/modules')

    Rake::Task['litmus:install_gems'].invoke

    Rake::Task['litmus:acceptance:parallel'].invoke

  rescue StandardError => e
    puts e.message
    raise e
  end

end
