require 'spec_helper'

module StringsSpec
  module Parsing

    # Cleans up the Registry and gives YARD some source code
    # to generate documentation for
    def parse(string, parser = :ruby)
      YARD::Registry.clear
      YARD::Parser::SourceParser.parse_string(string, parser)
    end

    # A custom matcher that allows us to compare aspects of a
    # Code Objects to the specified values. This gives us a
    # simplified way to ensure that the Code Object added to the
    # Registry is what we expect when testing handlers
    RSpec::Matchers.define :document_a do |arguments|
      match do |actual|
        @mismatches = compare_values(actual, arguments)
        @mismatches.empty?
      end

      failure_message do |actual|
        @mismatches.collect do |key, value|
          "Expected #{key} to be <#{value[1]}>, but got <#{value[0]}>."
        end.join("\n")
      end

      def compare_values(actual, expected)
        mismatched_arguments = {}
        expected.each do |key, value|
          actual_value = actual.send(key)
          if actual_value != value
            mismatched_arguments[key] = [actual_value, value]
          end
        end
        mismatched_arguments
      end
    end
  end
end

