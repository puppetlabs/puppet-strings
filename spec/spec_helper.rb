# frozen_string_literal: true

require 'mocha'
require 'mdl'
require 'rspec'
require 'json_spec'
require 'puppet/version'
require 'openvox-strings'
require 'openvox-strings/markdown'
require 'openvox-strings/markdown/base'
require 'openvox-strings/yard'

# Explicitly set up YARD once
OpenvoxStrings::Yard.setup!

# Enable testing of Puppet functions if running against 4.1+
TEST_PUPPET_FUNCTIONS = Puppet::Util::Package.versioncmp(Puppet.version, '4.1.0') >= 0

# Enable testing of Puppet language functions declared with return type if running against 4.8+
TEST_FUNCTION_RETURN_TYPE = Puppet::Util::Package.versioncmp(Puppet.version, '4.8.0') >= 0

# Enable testing of Plans if Puppet version is greater than 5.0.0
TEST_PUPPET_PLANS = Puppet::Util::Package.versioncmp(Puppet.version, '5.0.0') >= 0

# Enable testing of Data Types if Puppet version is greater than 4.1.0
TEST_PUPPET_DATATYPES = Puppet::Util::Package.versioncmp(Puppet.version, '4.1.0') >= 0

RSpec.configure do |config|
  config.mock_with :mocha

  config.before do
    # Always clear the YARD registry before each example
    YARD::Registry.clear
  end
end

def lint_markdown(content)
  # Load default mdl ruleset
  ruleset = MarkdownLint::RuleSet.new.tap(&:load_default)

  # Apply custom style to ruleset rules
  MarkdownLint::Style.load(File.join(__dir__, 'markdownlint_style.rb'), ruleset.rules)

  # Create a document
  doc = MarkdownLint::Doc.new(content, false)

  # Run the rules
  violations = []
  ruleset.rules.each do |id, rule|
    error_lines = rule.check.call(doc)
    next if error_lines.nil? || error_lines.empty?

    # record the error
    error_lines.each do |line|
      line += doc.offset # Correct line numbers for any yaml front matter
      violations << "#{line}: #{id} #{rule.description}: #{doc.lines[line - 1]}"
    end
  end
  violations
end

RSpec::Matchers.define :have_no_markdown_lint_errors do
  match do |actual|
    @violations = lint_markdown(actual)
    @violations.empty?
  end

  failure_message do |actual|
    "expected that #{(actual.length > 80) ? "#{actual.slice(0, 80).inspect}..." : actual.inspect} would have no markdown lint errors but got #{@violations.join("\n")}"
  end
end
