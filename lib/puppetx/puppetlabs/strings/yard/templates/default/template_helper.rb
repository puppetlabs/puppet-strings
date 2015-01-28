# A class containing helper methods to aid in the extraction of relevant data
# from comments and YARD tags
class TemplateHelper

  # Extracts data from comments which include the supported YARD tags
  def extract_tag_data(object)
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

    {:name => object.name, :desc => object.docstring, :examples => examples, :since => since_text, :return => return_details}
  end

  # Given the parameter information and YARD param tags, extracts the
  # useful information and returns it as an array of hashes which can
  # be printed and formatted as HTML
  #
  # @param parameters [Array] parameter details obtained programmatically
  # @param tags_hash [Array] parameter details obtained from comments
  # @param fq_name [Boolean] does this paramter have a fully qualified name?
  #
  # @return [Hash] The relevant information about each parameter
  # @option opts [String] :name The name of the parameter
  # @option opts [String] :fq_name The fully qualified parameter name
  # @option opts [String] :desc The description provided in the comment
  # @options opts [Array] :types The parameter type(s) specified in the comment
  # @options opts [Boolean] :exists? True only if the parameter exists in the documented logic and not just in a comment
  def extract_param_details(parameters, tags_hash, fq_name = false)
    parameter_info = []

    # Extract the information for parameters that actually exist
    parameters.each do |param|

      if fq_name
        param_name = param[0]
        fully_qualified_name = param[1]
      else
        param_name = param
      end

      param_tag = tags_hash.find { |tag| tag.name == param_name }

      description = param_tag.nil? ? nil : param_tag.text
      param_types = param_tag.nil? ? nil : param_tag.types

      param_details = {:name => param_name, :desc => description, :types => param_types, :exists? => true}

      if fq_name
        param_details[:fq_name] = fully_qualified_name
      end

      parameter_info.push(param_details)
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

  # Generates parameter information in situations where the information can only
  # come from YARD tags in the comments, not from the code itself. For now the only
  # use for this is 3x functions. In this case exists? will always be true since we
  # cannot verify if the paramter exists in the code itself. We must trust the user
  # to provide information in the comments that is accurate.
  #
  # @param param_tags [Array] parameter details obtained from comments
  #
  # @return [Hash] The relevant information about each parameter
  # @option opts [String] :name The name of the parameter
  # @option opts [String] :desc The description provided in the comment
  # @options opts [Array] :types The parameter type(s) specified in the comment
  # @options opts [Boolean] :exists? True only if the parameter exists in the documented logic and not just in a comment
  def comment_only_param_details(param_tags)
    return if param_tags.empty?

    parameter_info = []

    param_tags.each do |tag|
      parameter_info.push({:name => tag.name, :desc => tag.text, :types => tag.types, :exists? => true})
    end

    parameter_info
  end
end
