# frozen_string_literal: true

require 'puppet-strings/json'

# module for parsing Yard Registries and generating markdown
module PuppetStrings::Markdown
  require_relative 'markdown/puppet_class'
  require_relative 'markdown/function'
  require_relative 'markdown/defined_type'
  require_relative 'markdown/data_type'
  require_relative 'markdown/resource_type'
  require_relative 'markdown/puppet_task'
  require_relative 'markdown/puppet_plan'

  # Get classes that handle collecting and rendering each section/group.
  #
  # @return [Array[class]] The classes
  def self.groups
    [
      PuppetStrings::Markdown::PuppetClass,
      PuppetStrings::Markdown::DefinedType,
      PuppetStrings::Markdown::ResourceType,
      PuppetStrings::Markdown::Function,
      PuppetStrings::Markdown::DataType,
      PuppetStrings::Markdown::PuppetTask,
      PuppetStrings::Markdown::PuppetPlan,
    ]
  end

  # generates markdown documentation
  # @return [String] markdown doc
  def self.generate
    output = [
      "# Reference\n\n",
      "<!-- DO NOT EDIT: This document was generated by Puppet Strings -->\n\n",
      "## Table of Contents\n\n",
    ]

    # Create table of contents
    template = erb(File.join(__dir__, 'markdown', 'templates', 'table_of_contents.erb'))
    groups.each do |group|
      group_name = group.group_name
      items = group.items.map(&:toc_info)
      has_private = items.any? { |item| item[:private] }
      has_public = items.any? { |item| !item[:private] }

      output << template.result(binding)
    end

    # Create actual contents
    groups.each do |group|
      items = group.items.reject(&:private?)
      unless items.empty?
        output << "## #{group.group_name}\n\n"
        output.append(items.map(&:render))
      end
    end

    output.join
  end

  # mimicks the behavior of the json render, although path will never be nil
  # @param [String] path path to destination file
  def self.render(path = nil)
    if path.nil?
      puts generate
      exit
    else
      File.write(path, generate)
      YARD::Logger.instance.debug "Wrote markdown to #{path}"
    end
  end

  # Helper function to load an ERB template.
  #
  # @param [String] path The full path to the template file.
  # @return [ERB] Template
  def self.erb(path)
    unless Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.6.0')
      # This outputs warnings in Ruby 2.6+.
    end
    ERB.new(File.read(path), trim_mode: '-')
  end
end
