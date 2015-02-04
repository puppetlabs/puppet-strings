require 'spec_helper'
require 'puppet_x/puppetlabs/strings/yard/handlers/puppet_4x_function_handler'
require 'strings_spec/parsing'

describe PuppetX::PuppetLabs::Strings::YARD::Handlers::Puppet4xFunctionHandler do
  include StringsSpec::Parsing

  def the_method()
    YARD::Registry.at("Puppet4xFunctions#the_function")
  end

  def the_namespace()
    YARD::Registry.at("Puppet4xFunctions")
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

    expect(YARD::Registry.all).to be_empty
  end
end
