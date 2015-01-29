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

  # Generates the HTML to format the relevant data about parameters
  def generate_parameters(params)
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

      if param[:types]
        result << "(" << "<tt>" << param[:types].join(", ") << "</tt>" << ")"
      # Don't bother with TBD since 3x functions will never have type info per parameter.
      # However if the user does want to list a type for some reason that is still supported,
      # we just don't want to suggest that they need to
      elsif !param[:puppet_3_func]
        result << "(<tt>TBD</tt>)"
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
        result << "- <div class=\"inline\"><p> #{param[:desc]} </p></div>"
      end

      if !param[:exists?]
        result << "</strike>"
      end

      result << "</li>"
    end

    result.join
  end
end
