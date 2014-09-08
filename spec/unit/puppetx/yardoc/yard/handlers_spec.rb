require 'spec_helper'
require 'puppetx/yardoc/yard/handlers'

describe Puppetx::Yardoc::YARD::Handlers do

  # TODO: Relocate/refactor helper methods
  def parse_file(file, thisfile = __FILE__, log_level = log.level, ext = '.pp')
    Registry.clear
    path = File.join(File.dirname(thisfile), 'examples', file.to_s + ext)
    YARD::Parser::SourceParser.parse(path, [], log_level)
  end

  def parse(string)
    Registry.clear
    YARD::Parser::SourceParser.parse_string(string)
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

  describe "DefinedTypeHanlder" do
    it "should add a defined type object in the Registry" do
      parse_file :defined_type, __FILE__, log.level, '.pp'
      obj = Registry.at("wibbly::wobbly")
      expect(obj.type).to be(:definedtype)
    end
  end

  describe "FutureParserDispatchHandler" do
    def the_method()
      Registry.at("FutureParserFunctions#the_function")
    end

    def the_namespace()
      Registry.at("FutureParserFunctions")
    end

    it "should parse single-line documentation strings before a given function" do
      comment = "The summary"
      parse <<-RUBY
        # #{comment}
        Puppet::Functions.create_function(:the_function) do
        end
      RUBY

      expect(the_method).to document_a(:type => :method, :docstring => comment)
      expect(the_namespace).to document_a(:type => :puppetnamespace)
    end

    it "should parse multi-line documentation strings before a given function" do
      parse <<-RUBY
        # The summary
        #
        # The longer description
        Puppet::Functions.create_function(:the_function) do
        end
      RUBY

      comment = "The summary\n\nThe longer description"
      expect(the_method).to document_a(:type => :method, :docstring => comment)
      expect(the_namespace).to document_a(:type => :puppetnamespace)
    end

    it "should not parse documentation before a function if it is followed by two new lines" do
      parse <<-RUBY
        # The summary
        #
        # The longer description


        Puppet::Functions.create_function(:the_function) do
        end
      RUBY

      expect(the_method).to document_a(:type => :method, :docstring => "")
      expect(the_namespace).to document_a(:type => :puppetnamespace)
    end

    it "should not add anything to the Registry if incorrect ruby code is present" do
      parse <<-RUBY
        # The summary
        Puppet::Functions.create_function(:the function do
        end
      RUBY

      expect(Registry.all).to be_empty
    end
  end

  describe "ParserFunctionHanlder" do
    before(:each) {parse_file :puppet3_function, __FILE__, log.level, '.rb'}

    it "should add a module object to the Registry" do
      puppet_module = Registry.at("Puppet::Parser::Functions")
      expect(puppet_module.type).to be(:module)
    end

    it "should add a puppet namespace object to the Registry" do
      namespace = Registry.at("ParserFunctions")
      expect(namespace.type).to be(:puppetnamespace)
    end

    it "should add a method object to the Registry" do
      method = Registry.at("ParserFunctions#puppet3_function")
      expect(method.type).to be(:method)
    end
  end

  describe "HostClassDefintion" do
    before(:each) {parse_file :class, __FILE__, log.level, '.pp'}
    it "should add a host class object to the Registry" do
      hostclass = Registry.at("foo::bar")
      expect(hostclass.type).to be(:hostclass)
    end
  end
end
