module PuppetStrings::Yard::Handlers::Helpers
  # Logs a warning if a summary tag has more than 140 characters
  def self.validate_summary_tag(object)
    if object.has_tag?(:summary) && object.tag(:summary).text.length > 140
      log.warn "The length of the summary for #{object.type} '#{object.name}' exceeds the recommended limit of 140 characters."
    end
  end
end
