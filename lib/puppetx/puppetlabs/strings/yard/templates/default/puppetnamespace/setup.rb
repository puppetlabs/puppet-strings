include T('default/module')

def init
  sections :header, :box_info, :pre_docstring, T('docstring'),
    :method_summary, [:item_summary],
    :method_details_list, :method_details

  @methods = object.children
end

def header
  if @methods[0]['puppet_4x_function']
    @header_text = "Puppet 4 Functions"
  else
    @header_text = "Puppet 3 Functions"
  end

  erb(:header)
end

def box_info
  @source_files = []

  @methods.each do |method|
   # extract the file name and line number for each method
    file_name = method.files[0][0]
    line_number = method.files[0][1]

    @source_files.push([method.name, "#{file_name} (#{line_number})"])
  end

  erb(:box_info)
end

def method_summary
  @method_details = []

  @methods.each do |method|
    # If there are multiple sentences in the method description, only
    # use the first one for the summary. If the author did not include
    # any periods in their summary, include the whole thing
    first_sentence = method.docstring.match(/^(.*?)\./)
    brief_summary = first_sentence ? first_sentence : method.docstring

    return_tag = method.tags.find { |tag| tag.tag_name == "return"}
    return_types = return_tag.nil? ? nil : return_tag.types

    @method_details.push({:name => method.name, :short_desc => brief_summary, :return_types => return_types})
  end

  erb(:method_summary)
end

def method_details
  @class_details = []

  @methods.each do |object|
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

    param_details = nil

    if object['puppet_4x_function']
      param_tags = object.tags.find_all{ |tag| tag.tag_name == "param"}

      # Extract the source code
      source_code = object.source
      # Extract the parameters for the source code
      parameters = source_code.match(/(?:def .*)\((.*?)\)/)
      # Convert the matched string into an array of strings
      params = parameters.nil? ? nil :  parameters[1].split(/\s*,\s*/)

      param_details = extract_param_details(params, param_tags)
    end

    @class_details.push({:name => object.name, :desc => object.docstring, :examples => examples, :since => since_text, :return => return_details, :params => param_details})
  end

  erb(:docstring)
end

def extract_param_details(params_array, tags_hash)
  if params_array.nil?
    return
  end

  parameter_info = []

  # Extract the information for parameters that actually exist
  params_array.each do |param|
    param_tag = tags_hash.find { |tag| tag.name == param }

    description = param_tag.nil? ? nil : param_tag.text
    param_types = param_tag.nil? ? nil : param_tag.types

    parameter_info.push({:name => param, :desc => description, :types => param_types, :exists? => true})
  end

  # Check if there were any comments for parameters that do not exist
  tags_hash.each do |tag|
    param_exists = false
    parameter_info.each do |parameter|
      if parameter[:name] == tag.name
        param_exists = true
      end
    end
    if !param_exists
      parameter_info.push({:name => tag.name, :desc => tag.text, :types => tag.types, :exists? => false})
    end
  end

  parameter_info
end
