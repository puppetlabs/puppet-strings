require 'spec_helper'
require 'puppetx/puppetlabs/strings/yard/handlers/defined_type_handler'
require 'strings_spec/parsing'


describe Puppetx::PuppetLabs::Strings::YARD::Handlers::DefinedTypeHandler do
  include StringsSpec::Parsing

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
