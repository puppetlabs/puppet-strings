require 'spec_helper'

module StringsSpec
  module Parsing

    def parse(string, parser = :ruby)
      Registry.clear
      YARD::Parser::SourceParser.parse_string(string, parser)
    end

    RSpec::Matchers.define :document_a do |arguments|
      match do |actual|
        compare_values(actual).empty?
      end

      failure_message do |actual|
        mismatches = compare_values(actual)
        mismatches.collect do |key, value|
          "Expected #{key} to be <#{value[1]}>, but got <#{value[0]}>."
        end.join("\n")
      end

      def compare_values(actual)
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

