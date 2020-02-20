if Bundler.rubygems.find_name('puppet_litmus').any?
  require 'puppet_litmus/rake_tasks'

  # This is a _really_ horrible monkey-patch to fix up https://github.com/puppetlabs/bolt/issues/1614
  # Based on resolution https://github.com/puppetlabs/bolt/pull/1620
  # This can be removed once this is fixed, released into Bolt and into Litmus
  require 'bolt_spec/run'
  module BoltSpec
    module Run
      class BoltRunner
        class << self
          alias_method :original_with_runner, :with_runner
        end

        def self.with_runner(config_data, inventory_data)
          original_with_runner(deep_duplicate_object(config_data), deep_duplicate_object(inventory_data)) { |runner| yield runner }
        end

        # From https://github.com/puppetlabs/pdk/blob/master/lib/pdk/util.rb
        # Workaround for https://github.com/puppetlabs/bolt/issues/1614
        def self.deep_duplicate_object(object)
          if object.is_a?(Array)
            object.map { |item| deep_duplicate_object(item) }
          elsif object.is_a?(Hash)
            hash = object.dup
            hash.each_pair { |key, value| hash[key] = deep_duplicate_object(value) }
            hash
          else
            object
          end
        end
      end
    end
  end
end

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
    require 'bolt_spec/run'
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
    # TODO: Currently this is Linux targets only. no windows localhost
    tmp_path = '/tmp/'
    puts 'Copying gem to targets...'
    run_local_command("bolt file upload #{gem_tar} #{tmp_path}#{File.basename(gem_tar)} --targets #{target_string} --inventoryfile inventory.yaml")

    # Install dependent gems
    puts 'Installing yard gem...'
    install_remote_gem('yard', target_nodes, inventory_hash)
    puts 'Installing rgen gem...'
    install_remote_gem('rgen', target_nodes, inventory_hash)
    # Install puppet-strings
    puts 'Installing puppet-strings gem...'
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
