require 'spec_helper'
require 'puppetx/puppetlabs/strings/yard/handlers/host_class_handler'
require 'strings_spec/parsing'

describe Puppetx::PuppetLabs::Strings::YARD::Handlers::HostClassHandler do
  include StringsSpec::Parsing

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
