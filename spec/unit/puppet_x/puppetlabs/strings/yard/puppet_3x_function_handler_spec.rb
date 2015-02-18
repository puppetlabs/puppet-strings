require 'spec_helper'
require 'puppet_x/puppetlabs/strings/yard/handlers/puppet_3x_function_handler'
require 'strings_spec/parsing'

describe PuppetX::PuppetLabs::Strings::YARD::Handlers::Puppet3xFunctionHandler do
  include StringsSpec::Parsing

  def the_method()
    YARD::Registry.at("Puppet3xFunctions#the_function")
  end

  def the_namespace()
    YARD::Registry.at("Puppet3xFunctions")
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

  it "should process documentation if only one option is passed to newfunction" do
    parse <<-RUBY
      newfunction(:the_functiion) do |args|
      end
    RUBY

      expect(the_namespace).to document_a(:type => :puppetnamespace)
  end
end
