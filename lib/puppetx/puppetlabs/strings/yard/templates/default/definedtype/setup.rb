include T('default/module')

def init
  sections :header, :box_info, :pre_docstring, :docstring, :parameter_details
end

def parameter_details
  return if object.parameters.empty?

  param_tags = object.tags.find_all{ |tag| tag.tag_name == "param"}
  params = object.parameters

  @param_details = []

  @param_details = extract_param_details(params, param_tags)

  erb(:parameter_details)
end

def docstring
  examples = Hash.new
  example_tags = object.tags.find_all { |tag| tag.tag_name == "example" }
  example_tags.each do |example|
    examples["#{example.name}"] = example.text
  end

  return_tag = object.tags.find { |tag| tag.tag_name == "return"}
  return_text = return_tag.nil? ? nil : return_tag.text
  return_types = return_tag.nil? ? nil : return_tag.types
  return_details = (return_text.nil? && return_types.nil?) ? nil : [return_text, return_types]

  since_tag = object.tags.find { |tag| tag.tag_name == "since"}
  since_text = since_tag.nil? ? nil : since_tag.text

  @class_details = {:name => object.name, :desc => object.docstring, :examples => examples, :since => since_text, :return => return_details}

  erb(:docstring)
end

# Given the parameter information and YARD param tags, extracts the
# useful information and returns it as an array of hashes which can
# be printed and formatted in the paramters_details erb file
#
# @param params_hash [Array] parameter details obtained programmatically
# @param tags_hash [Array] parameter details obtained from comments
#
# @return [Hash] The relevant information about each parameter
# @option opts [String] :name The name of the parameter
# @option opts [String] :fq_name The fully qualified parameter name
# @option opts [String] :desc The description provided in the comment
# @options opts [Array] :types The parameter type(s) specified in the comment
# @options opts [Boolean] :exists? True only if the parameter actually exists and just not just defined in the comment
def extract_param_details(params_hash, tags_hash)
  parameter_info = []

  # Extract the information for parameters that actually exist
  params_hash.each do |param|
    param_tag = tags_hash.find { |tag| tag.name == param[0] }

    description = param_tag.nil? ? nil : param_tag.text
    param_types = param_tag.nil? ? nil : param_tag.types

    parameter_info.push({:name => param[0], :fq_name => param[1], :desc => description, :types => param_types, :exists? => true})
  end

  # Check if there were any comments for parameters that do not exist
  tags_hash.each do |tag|
    param_exists = false
    parameter_info.each do |parameter|
      if parameter.has_value?(tag.name)
        param_exists = true
      end
    end
    if !param_exists
      parameter_info.push({:name => tag.name, :fq_name => nil, :desc => tag.text, :types => tag.types, :exists? => false})
    end
  end

  parameter_info
end
