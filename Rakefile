require 'puppet_litmus/rake_tasks' if Bundler.rubygems.find_name('puppet_litmus').any?
require 'puppetlabs_spec_helper/tasks/fixtures'
require 'bundler/gem_tasks'
require 'puppet-lint/tasks/puppet-lint'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.exclude_pattern = "spec/acceptance/**/*.rb"
end

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

namespace :litmus do
  # Install the puppet module fixture on a collection of nodes
  #
  # @param :target_node_name [Array] nodes on which to install a puppet module for testing.
  desc 'install_module_fixtures - build and install module fixtures'
  task :install_module_fixtures, [:target_node_name] do |_task, args|
    inventory_hash = inventory_hash_from_inventory_file
    target_nodes = find_targets(inventory_hash, args[:target_node_name])
    if target_nodes.empty?
      puts 'No targets found'
      exit 0
    end
    include BoltSpec::Run
    require 'pdk/module/build'

    module_fixture_dir = File.expand_path(File.join(File.dirname(__FILE__), 'spec', 'fixtures', 'acceptance', 'modules', 'test'))
    module_tar = nil
    Dir.chdir(module_fixture_dir) do
      opts = {}
      opts[:force] = true
      builder = PDK::Module::Build.new(opts)
      module_tar = builder.build
      puts 'Built'
      module_tar = Dir.glob('pkg/*.tar.gz').max_by { |f| File.mtime(f) }
      raise "Unable to find package in 'pkg/*.tar.gz'" if module_tar.nil?
      module_tar = File.expand_path(module_tar)
    end

    target_string = if args[:target_node_name].nil?
                      'all'
                    else
                      args[:target_node_name]
                    end
    # TODO: Currently this is Linux only
    tmp_path = '/tmp/'
    run_local_command("bundle exec bolt file upload #{module_tar} #{tmp_path}#{File.basename(module_tar)} --nodes #{target_string} --inventoryfile inventory.yaml")
    install_module_command = "puppet module install #{tmp_path}#{File.basename(module_tar)}"
    result = run_command(install_module_command, target_nodes, config: nil, inventory: inventory_hash)
    if result.is_a?(Array)
      result.each do |node|
        puts "#{node['node']} failed #{node['result']}" if node['status'] != 'success'
      end
    else
      raise "Failed trying to run '#{install_module_command}' against inventory."
    end
    puts 'Installed'
  end

  def install_remote_gem(gem_name, target_nodes, inventory_hash)
    # TODO: Currently this is Linux only
    install_command = "/opt/puppetlabs/puppet/bin/gem install #{gem_name}"
    result = run_command(install_command, target_nodes, config: nil, inventory: inventory_hash)
    if result.is_a?(Array)
      result.each do |node|
        puts "#{node['node']} failed #{node['result']}" if node['status'] != 'success'
      end
    else
      raise "Failed trying to run '#{install_command}' against inventory."
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
    include BoltSpec::Run

    # Build the gem
    `gem build puppet-strings.gemspec --quiet`
    result = $CHILD_STATUS
    raise "Unable to build the puppet-strings gem. Returned exit code #{result.exitstatus}" unless result.exitstatus.zero?
    puts 'Built'
    # Find the gem build artifact
    gem_tar = Dir.glob('puppet-strings-*.gem').max_by { |f| File.mtime(f) }
    raise "Unable to find package in 'puppet-strings-*.gem'" if gem_tar.nil?
    gem_tar = File.expand_path(gem_tar)

    target_string = if args[:target_node_name].nil?
                      'all'
                    else
                      args[:target_node_name]
                    end
    # TODO: Currently this is Linux only
    tmp_path = '/tmp/'
    run_local_command("bundle exec bolt file upload #{gem_tar} #{tmp_path}#{File.basename(gem_tar)} --nodes #{target_string} --inventoryfile inventory.yaml")


    # Install dependent gems
    install_remote_gem('yard', target_nodes, inventory_hash)
    install_remote_gem('rgen', target_nodes, inventory_hash)
    # Install puppet-strings
    install_remote_gem(tmp_path + File.basename(gem_tar), target_nodes, inventory_hash)
    puts 'Installed'
  end
end

task(:rubocop) do
  require 'rubocop'
  cli = RuboCop::CLI.new
  result = cli.run(%w(-D -f s))
  abort unless result == RuboCop::CLI::STATUS_SUCCESS
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
