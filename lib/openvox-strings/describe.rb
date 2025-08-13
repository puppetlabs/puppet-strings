# frozen_string_literal: true

require 'json'
require 'openvox-strings/json'

# The module for command line documentation related functionality.
module OpenvoxStrings::Describe
  # Renders requested types or a summarized list in the current YARD registry to STDOUT.
  # @param [Array] describe_types The list of names of the types to be displayed.
  # @param [bool] list_types Create the summarized list instead of describing each type.
  # @param [bool] show_type_providers Show details of the providers of a specified type.
  # @param [bool] list_providers Create a summarized list of providers.
  # @return [void]
  def self.render(describe_types = [], list_types = false, show_type_providers = true, list_providers = false)
    document = {
      defined_types: YARD::Registry.all(:puppet_defined_type).sort_by!(&:name).map!(&:to_hash),
      resource_types: YARD::Registry.all(:puppet_type).sort_by!(&:name).map!(&:to_hash),
      providers: YARD::Registry.all(:puppet_provider).sort_by!(&:name).map!(&:to_hash),
    }
    # if --list flag passed, produce a summarized list of types
    if list_types
      puts 'These are the types known to puppet:'
      document[:resource_types].each { |t| list_one(t) }

    # if a type(s) has been passed, show the details of that type(s)
    elsif describe_types
      type_names = {}
      describe_types.each { |name| type_names[name] = true }

      document[:resource_types].each do |t|
        show_one_type(t, show_type_providers) if type_names[t[:name].to_s]
      end

    # if --providers flag passed, produce a summarized list of providers
    elsif list_providers
      puts 'These are the providers known to puppet:'
      document[:providers].each { |t| list_one(t) }
    end
  end

  def self.show_one_type(resource_type, providers = true)
    puts format("\n%<name>s\n%<underscore>s", name: resource_type[:name], underscore: '=' * resource_type[:name].length)
    puts resource_type[:docstring][:text]

    combined_list = (resource_type[:parameters].nil? ? [] : resource_type[:parameters]) +
                    (resource_type[:properties].nil? ? [] : resource_type[:properties])

    return unless combined_list.any?

    puts "\nParameters\n----------"
    combined_list.sort_by { |p| p[:name] }.each { |p| show_one_parameter(p) }
    return unless providers

    puts "\nProviders\n---------"
    resource_type[:providers]&.sort_by { |p| p[:name] }&.each { |p| puts p[:name].to_s.ljust(15) }
  end

  def self.show_one_parameter(parameter)
    puts format("\n- **%<name>s**\n", name: parameter[:name])
    puts parameter[:description]
    puts format('Valid values are `%<values>s`.', values: parameter[:values].join('`, `')) unless parameter[:values].nil?
    puts format('Requires features %<required_features>s.', required_features: parameter[:required_features]) unless parameter[:required_features].nil?
  end

  def self.list_one(object)
    targetlength = 48
    shortento = targetlength - 4
    contentstring = object[:docstring][:text]
    end_of_line = contentstring.index("\n") # "." gives closer results to old describeb, but breaks for '.k5login'
    contentstring = contentstring[0..end_of_line] unless end_of_line.nil?
    contentstring = "#{contentstring[0..shortento]} ..." if contentstring.length > targetlength

    puts "#{object[:name].to_s.ljust(15)} - #{contentstring}"
  end
end
