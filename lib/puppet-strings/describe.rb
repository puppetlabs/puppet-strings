require 'json'
require 'puppet-strings/json'

# The module for command line documentation related functionality.
module PuppetStrings::Describe
  # Renders requested types or a summarized list in the current YARD registry to STDOUT.
  # @param [Array] describe_types The list of names of the types to be displayed.
  # @param [bool] list Create the summarized list instead of describing each type.
  # @param [bool] providers Show details of the providers.
  # @return [void]
  def self.render(describe_types = [], list = false, providers = false)
    document = {
      defined_types: YARD::Registry.all(:puppet_defined_type).sort_by!(&:name).map!(&:to_hash),
      resource_types: YARD::Registry.all(:puppet_type).sort_by!(&:name).map!(&:to_hash),        
    }

    if list
      puts "These are the types known to puppet:"
      document[:resource_types].each { |t| list_one_type(t) }
    else
      document[:providers] = YARD::Registry.all(:puppet_provider).sort_by!(&:name).map!(&:to_hash)

      type_names = {}
      describe_types.each { |name| type_names[name] = true }

      document[:resource_types].each do |t|
        show_one_type(t, providers) if type_names[t[:name].to_s]
      end
    end
  end

  def self.show_one_type(resource_type, providers = false)
    puts "\n%{name}\n%{underscore}" % { name: resource_type[:name], underscore: "=" * resource_type[:name].length }
    puts resource_type[:docstring][:text]

    combined_list = (resource_type[:parameters].nil? ? [] : resource_type[:parameters]) +
                    (resource_type[:properties].nil? ? [] : resource_type[:properties])

    if combined_list.any?
      puts "\nParameters\n----------"
      combined_list.sort_by { |p| p[:name] }.each { |p| show_one_parameter(p) }
      puts "\nProviders\n---------"
    end
    #Show providers here - list or provide details      
  end

  def self.show_one_parameter(parameter)
    puts "\n- **%{name}**\n" % { name: parameter[:name] }
    puts parameter[:description]
    puts "Valid values are `%{values}`." % { values: parameter[:values].join("`, `") } unless parameter[:values].nil?
    puts "Requires features %{required_features}." % { required_features: parameter[:required_features] } unless parameter[:required_features].nil?
  end

  def self.list_one_type(type)
    targetlength = 48
    shortento = targetlength - 4
    contentstring = type[:docstring][:text]
    end_of_line = contentstring.index("\n")  # "." gives closer results to old describeb, but breaks for '.k5login'
    if !end_of_line.nil?
      contentstring = contentstring[0..end_of_line]
    end
    if contentstring.length > targetlength
      contentstring = contentstring[0..shortento] + ' ...'
    end
    
    puts "%-15s - %-s" % [type[:name], contentstring]
  end
end
