require "puppet"

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
  # @param fq_name [Boolean] does this parameter have a fully qualified name?
  #
  # @return [Hash] The relevant information about each parameter with the following keys/values:
  #   {:name    => [String] The name of the parameter
  #    :fq_name => [String] The fully qualified parameter name
  #    :desc    => [String] The description provided in the comment
  #    :types   => [Array] The parameter type(s) specified in the comment
  #    :exists  => [Boolean] True only if the parameter exists in the documented logic and not just in a comment}
  def extract_param_details(parameters, tags_hash, fq_name = false)
    parameter_info = []

    # Extract the information for parameters that exist
    # as opposed to parameters that are defined only in the comments
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
  # cannot verify if the parameter exists in the code itself. We must trust the user
  # to provide information in the comments that is accurate.
  #
  # @param param_tags [Array] parameter details obtained from comments
  #
  # @return [Hash] The relevant information about each parameter with the following keys/values:
  #   {:name          => [String] The name of the parameter
  #    :desc          => [String] The description provided in the comment
  #    :types         => [Array] The parameter type(s) specified in the comment
  #    :exists        => [Boolean] True only if the parameter exists in the documented logic and not just in a comment
  #    :puppet_3_func => [Boolean] Are these parameters for a puppet 3 function? (relevant in HTML generation)}
  def comment_only_param_details(param_tags)
    return if param_tags.empty?

    parameter_info = []

    param_tags.each do |tag|
      parameter_info.push({:name => tag.name, :desc => tag.text, :types => tag.types, :exists? => true, :puppet_3_func => true})
    end

    parameter_info
  end

  # Check that any types specified in the docstrings match the actual method
  # types. This is used by puppet 4x functions and defined types.
  # @param object the code object to examine for parameters names
  def check_types_match_docs(object, params_hash)
    # We'll need this to extract type info from the type specified by the
    # docstring.
    type_parser = Puppet::Pops::Types::TypeParser.new
    type_calculator = Puppet::Pops::Types::TypeCalculator.new

    object.type_info.each do |function|
      function.keys.each do |key|
        if function[key].class == String
          begin
            instantiated = type_parser.parse function[key].gsub(/'/, '').gsub(/"/, "")
          rescue Puppet::ParseError
            # Likely the result of a malformed type
            next
          end
        else
          instantiated = function[key]
        end
        params_hash.each do |param|
          if param[:name] == key and param[:types] != nil
            param[:types].each do |type|
              param_instantiated = type_parser.parse type
              if not type_calculator.assignable? instantiated, param_instantiated
                actual_types = object.type_info.map do |sig|
                  sig[key]
                end
                # Get the locations where the object can be found. We only care about
                # the first one.
                locations = object.files
                # If the locations aren't in the shape we expect then report that
                # the file number couldn't be determined.
                if locations.length >= 1 and locations[0].length == 2
                  file = locations[0][0]
                  line = locations[0][1]
                  warning = "@param tag types do not match the code. The " +
                    "#{param[:name]} parameter is declared as types #{param[:types]} in " +
                    "the docstring, but the code specifies the types " +
                    "#{actual_types.inspect} in file #{file} near line #{line}"
                else
                  warning = "@param tag types do not match the code. The " +
                    "#{param[:name]} parameter is declared as types #{param[:types]} in " +
                    "the docstring, but the code specifies the types " +
                    "#{actual_types.inspect} Sorry, the file and line number could" +
                    "not be determined."
                end
                log.warn warning
              end
            end
          end
        end
      end
    end
  end

  # Check that the actual function parameters match what is stated in the docs.
  # If there is a mismatch, print a warning to stderr.
  # This is necessary for puppet classes and defined types. This type of
  # warning will be issued for ruby code by the ruby docstring parser.
  # @param object the code object to examine for parameters names
  def check_parameters_match_docs(object)
    param_tags = object.tags.find_all{ |tag| tag.tag_name == "param"}
    names = object.parameters.map {|l| l.first.gsub(/\W/, '') }
    locations = object.files
    param_tags.each do |tag|
      if not names.include?(tag.name)
        if locations.length >= 1 and locations[0].length == 2
          file_name = locations[0][0]
          line_number = locations[0][1]
          $stderr.puts "[warn]: The parameter #{tag.name} is documented, but doesn't exist in your code, in file #{file_name} near line #{line_number}"
        else
          $stderr.puts "[warn]: The parameter #{tag.name} is documented, but doesn't exist in your code. Sorry, the file and line number could not be determined."
        end
      end
    end
  end
end
