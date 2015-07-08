include T('default/module')

require File.join(File.dirname(__FILE__),'../html_helper')
require File.join(File.dirname(__FILE__),'../template_helper')

def init
  sections :header, :box_info,
    :method_summary, [:item_summary],
    :method_details_list, [T('method_details')]

  @methods = object.children
  @template_helper = TemplateHelper.new
end

def header
  # The list is expected to only contain one type of function
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
  @html_helper = HTMLHelper.new

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

def method_details_list
  @class_details = []
  @html_helper = HTMLHelper.new

  @methods.each do |object|

    method_info = @template_helper.extract_tag_data(object)
    param_details = nil
    param_tags = object.tags.find_all{ |tag| tag.tag_name == "param"}

    if object['puppet_4x_function']
      # Extract the source code
      source_code = object.source
      # Extract the parameters for the source code
      parameters = source_code.match(/(?:def .*)\((.*?)\)/)
      # Convert the matched string into an array of strings
      params = parameters.nil? ? nil :  parameters[1].split(/\s*,\s*/)

      param_details = @template_helper.extract_param_details(params, param_tags) unless params.nil?
      @template_helper.check_types_match_docs object, param_details
    else
      param_details = @template_helper.comment_only_param_details(param_tags)
    end

    method_info[:params] = param_details

    @class_details.push(method_info)
  end

  erb(:method_details_list)
end
