require 'spec_helper'
require 'puppetx/yardoc/yard/handlers'

describe Puppetx::Yardoc::YARD::Handlers do

  # TODO: Relocate/refactor helper methods
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

  #TODO: Split up tests for each handler into their own files
  describe "DefinedTypeHanlder" do
    def the_definedtype()
      Registry.at("foo::bar")
    end

    it "should parse single-line documentation strings before a given defined type" do
      comment = "Definition: foo::bar"
      puppet_code =  <<-PUPPET
        # #{comment}
        define foo::bar ($baz) { }
      PUPPET

      parse(puppet_code, :puppet)

      expect(the_definedtype).to document_a(:type => :definedtype, :docstring => comment)
    end

    it "should parse multi-line documentation strings before a given defined type" do
      puppet_code =  <<-PUPPET
        # Definition: foo::bar
        #
        # This class does some stuff
        define foo::bar ($baz) { }
      PUPPET

      parse(puppet_code, :puppet)

      comment = "Definition: foo::bar\nThis class does some stuff"
      expect(the_definedtype).to document_a(:type => :definedtype, :docstring => comment)
    end

    it "should not parse documentation before a function if it is followed by a new line" do
      puppet_code =  <<-PUPPET
        # Definition: foo::bar

        define foo::bar ($baz) { }
      PUPPET

      parse(puppet_code, :puppet)

      expect(the_definedtype).to document_a(:type => :definedtype, :docstring => "")
    end
    it "should not add anything to the Registry if incorrect puppet code is present" do
      puppet_code =  <<-PUPPET
        # Definition: foo::bar
        This is not puppet code
      PUPPET

      parse(puppet_code, :puppet)

      expect(Registry.all).to be_empty
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
        This is not ruby code
      RUBY

      expect(Registry.all).to be_empty
    end
  end

  describe "ParserFunctionHanlder" do
    def the_method()
      Registry.at("ParserFunctions#the_function")
    end

    def the_namespace()
      Registry.at("ParserFunctions")
    end

    it "should parse single-line documentation strings before a given function" do
      comment = "The summary"
      parse <<-RUBY
        # #{comment}
        newfunction(:the_function, :type => rvalue) do |args|
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
        newfunction(:the_function, :type => rvalue) do |args|
        end
      RUBY

      comment = "The summary\n\nThe longer description"
      expect(the_method).to document_a(:type => :method, :docstring => comment)
      expect(the_namespace).to document_a(:type => :puppetnamespace)
    end

    it "should not parse documentation before a function if it is followed by two new lines" do
      parse <<-RUBY
        # The summary


        newfunction(:the_function, :type => rvalue) do |args|
        end
      RUBY

      expect(the_method).to document_a(:type => :method, :docstring => "")
      expect(the_namespace).to document_a(:type => :puppetnamespace)
    end
  end

  describe "HostClassDefintion" do
    def the_hostclass()
       Registry.at("foo::bar")
    end

    it "should parse single-line documentation strings before a given class" do
      comment = "Class: foo::bar"
      puppet_code = <<-PUPPET
        # #{comment}
        class foo::bar { }
      PUPPET

      parse(puppet_code, :puppet)

      expect(the_hostclass).to document_a(:type => :hostclass, :docstring => comment)
    end

    it "should parse multi-line documentation strings before a given class" do
      puppet_code = <<-PUPPET
        # Class: foo::bar
        #
        # This class does some stuff
        class foo::bar { }
      PUPPET

      parse(puppet_code, :puppet)

      comment = "Class: foo::bar\nThis class does some stuff"
      expect(the_hostclass).to document_a(:type => :hostclass, :docstring => comment)
    end

    it "should not parse documentation before a class if it is followed by a new line" do
      puppet_code = <<-PUPPET
        # Class: foo::bar

        class foo::bar { }
      PUPPET

      parse(puppet_code, :puppet)

      expect(the_hostclass).to document_a(:type => :hostclass, :docstring => "")
    end
  end
end
