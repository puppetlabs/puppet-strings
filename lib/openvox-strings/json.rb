# frozen_string_literal: true

require 'json'

# The module for JSON related functionality.
module OpenvoxStrings::Json
  # Renders the current YARD registry as JSON to the given file (or STDOUT if nil).
  # @param [String] file The path to the output file to render the registry to. If nil, output will be to STDOUT.
  # @return [void]
  def self.render(file = nil)
    document = {
      puppet_classes: YARD::Registry.all(:puppet_class).sort_by!(&:name).map!(&:to_hash),
      data_types: YARD::Registry.all(:puppet_data_type).sort_by!(&:name).map!(&:to_hash),
      data_type_aliases: YARD::Registry.all(:puppet_data_type_alias).sort_by!(&:name).map!(&:to_hash),
      defined_types: YARD::Registry.all(:puppet_defined_type).sort_by!(&:name).map!(&:to_hash),
      resource_types: YARD::Registry.all(:puppet_type).sort_by!(&:name).map!(&:to_hash),
      providers: YARD::Registry.all(:puppet_provider).sort_by!(&:name).map!(&:to_hash),
      puppet_functions: YARD::Registry.all(:puppet_function).sort_by!(&:name).map!(&:to_hash),
      puppet_tasks: YARD::Registry.all(:puppet_task).sort_by!(&:name).map!(&:to_hash),
      puppet_plans: YARD::Registry.all(:puppet_plan).sort_by!(&:name).map!(&:to_hash),
      # TODO: Need Ruby documentation?
    }

    if file
      File.open(file, 'w') do |f|
        f.write(JSON.pretty_generate(document))
        f.write("\n")
      end
    else
      puts JSON.pretty_generate(document)
    end
  end
end
