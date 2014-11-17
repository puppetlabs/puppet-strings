include T('default/module')

def init
  sections :header, :box_info, :pre_docstring, :docstring, :parameter_details
end

def parameter_details
  return if object.parameters.empty?

  param_tags = object.tags.find_all{ |tag| tag.tag_name == "param"}
  params = object.parameters
  @param_details = []

  params.zip(param_tags).each do |param, tag|
    description = tag.nil? ? nil : tag.text
    param_types = tag.nil? ? nil : tag.types
    @param_details.push({:name => param[0], :module => param[1], :desc => description, :types => param_types})
  end

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
