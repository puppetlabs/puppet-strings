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

      if !param[:exists?]
        result << "<strike>"
      end

      result << "<span class=\"name\">#{param[:name]} </span>"
      result << "<span class=\"type\">"

      if param[:types]
        result << "(" << "<tt>" << param[:types].join(", ") << "</tt>" << ")"
      else
        result << "(<tt>TBD</tt>)"
      end
        result << "</span>"

      # This is only relevant for manifests, not puppet functions
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
