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

def extract_param_details(params_hash, tags_hash)

  parameter_info = []

  # Extract the information for parameters that actually exist
  params_hash.each do |param|
    param_tag = tags_hash.find { |tag| tag.name == param[0] }

    description = param_tag.nil? ? nil : param_tag.text
    param_types = param_tag.nil? ? nil : param_tag.types

    parameter_info.push({:name => param[0], :module => param[1], :desc => description, :types => param_types, :exists? => true})
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
      parameter_info.push({:name => tag.name, :module => nil, :desc => tag.text, :types => tag.types, :exists? => false})
    end
  end

  parameter_info
end
