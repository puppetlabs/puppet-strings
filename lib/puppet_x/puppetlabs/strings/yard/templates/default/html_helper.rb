# A class containing helper methods to aid the generation of HTML
# given formatted data
class HTMLHelper

  # Generates the HTML to format the relevant data about return values
  def generate_return_types(types, desc = nil)
    result = []

    result << "(<span class=\"type\"><tt>" << types.join(", ") << "</tt></span>)"

    if !desc.nil?
      result << "- <div class=\"inline\"><p>#{desc}</p></div>"
    end

    result.join
  end

  def generate_features features, object
    result = []

    if features
      features.each do |feat|
        result << "<li>"
        result << "<span class=\"name\">#{feat[:name]} </span>"
        if feat[:desc]
          result << "- <br/><div class=\"inline\"><p> #{feat[:desc]} </p></div>"
        end
        if feat[:methods]
          result << "<h3> Methods </h3>"
          result << "<ul>"
          feat[:methods].each do |method|
            result << "<li> <tt>" << method << "</tt> </li>"
          end
          result << "</ul>"
        end
        result << "</li>"
      end
    end
    result.join
  end

  # Generates the HTML to format the relevant data about parameters
  def generate_parameters(params, object)
    result = []

    params.each do |param|
      result << "<li>"

      # Parameters which are documented in the comments but not
      # present in the code itself are given the strike through
      # styling in order to show the reader that they do not actually
      # exist
      if !param[:exists?]
        result << "<strike>"
      end

      result << "<span class=\"name\">#{param[:name]} </span>"
      result << "<span class=\"type\">"

      # If the docstring specifies types, use those
      if param[:types]
        result << "(" << "<tt>" << param[:types].join(", ") << "</tt>" << ")"
      # Otherwise, if typing information could be extracted from the object
      # itself, use that
      elsif object.type_info
        # If the parameter name includes the default value, scrub that.
        if param[:name].match(/([^=]*)=/)
          param_name = $1
        else
          param_name = param[:name]
        end
        # Collect all the possible types from the object. If no such type
        # exists for this parameter name don't do anything.
        possible_types = object.type_info.map {
          |sig| sig[param_name] or nil
        }.compact

        # If no possible types could be determined, put the type down as
        # Unknown
        if possible_types == []
          result << "(" << "<tt>Unknown</tt>" << ")"
        else
          result << "(" << "<tt>" << possible_types.join(", ") << "</tt>" << ")"
        end
      # Give up. It can probably be anything.
      elsif not (param[:puppet_3_func] or param[:puppet_type])
        result << "(<tt>Unknown</tt>)"
      end
      if param[:puppet_type] and param[:parameter]
        result << "(Parameter) "
      elsif param[:puppet_type] and param[:property]
        result << "(Property) "
      end

      if param[:namevar]
        result << "(Namevar) "
      end
      if param[:default]
        result << " Default value: <tt>" << param[:default] << "</tt> "
      end

      result << "</span>"

      # This is only relevant for manifests, not puppet functions
      # This is due to the fact that the scope of a parameter (as illustrated by
      # by it's fully qualified name) is not relevant for the parameters in puppet
      # functions, but may be for components of a manifest (i.e. classes)
      unless param[:fq_name].nil?
        result << "<tt> => #{param[:fq_name]}</tt>"
      end

      if param[:desc]
        result << " - <div class=\"inline\"><p> #{param[:desc]} </p></div>"
      end

      if !param[:exists?]
        result << "</strike>"
      end

      if param[:allowed_values] and param[:allowed_values] != []
        result << "\n<b> Allowed Values: </b>"
        result << "<ul>"
        param[:allowed_values].each do |value_thing|
          result << "<li>"
          result << "<tt>" << value_thing.first << "</tt>"
          if value_thing[1]
            result <<  " only available if " << "<tt>" << value_thing[1] << "</tt>"
          end
          result << "</li>"
        end
        result << "</ul>"
      end

      result << "</li>"
    end

    result.join
  end
end
