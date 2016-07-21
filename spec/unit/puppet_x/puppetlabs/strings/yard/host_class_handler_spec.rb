require 'spec_helper'
require 'lib/strings_spec/module_helper'
require 'puppet/face/strings'
require 'puppet_x/puppetlabs/strings/yard/handlers/host_class_handler'
require 'strings_spec/parsing'

describe PuppetX::PuppetLabs::Strings::YARD::Handlers::HostClassHandler do
  include StringsSpec::Parsing

  def the_hostclass()
    YARD::Registry.at("foo::bar")
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

    comment = "Class: foo::bar\n\nThis class does some stuff"
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

  it "should generate the correct namespace " do
    puppet_code =  <<-PUPPET
        class puppet_enterprise::mcollective::client::certs { }
    PUPPET

    YARD::CodeObjects.send(:remove_const, :CONSTANTSTART)
    YARD::CodeObjects::CONSTANTSTART = /^[a-zA-Z]/

    parse(puppet_code, :puppet)
    # If the namespace is not correctly generated, we will not be able to find the
    # object via this name, meaning namespace will be nil
    namespace = YARD::Registry.at("puppet_enterprise::mcollective::client::certs")

    expect(namespace).to_not be_nil
  end
  it "should not issue just one warning if the parameter types don't match." do
    YARD::Registry.clear
    # FIXME The type information here will change with the next version of
    # puppet. `expected` is the output expected from the stable branch. The
    # output from the master branch will use this instead:
    # "...specifies the types [String] in file..."
    expected_stout = <<-output
Files:           1
Modules:         0 (    0 undocumented)
Classes:         0 (    0 undocumented)
Constants:       0 (    0 undocumented)
Attributes:      0 (    0 undocumented)
Methods:         0 (    0 undocumented)
Puppet Classes:     1 (    0 undocumented)
Puppet Defined Types:     0 (    0 undocumented)
Puppet Types:     0 (    0 undocumented)
Puppet Providers:     0 (    0 undocumented)
 100.00% documented
    output
    expected_stderr = "[warn]: @param tag types do not match the code. The ident\n    parameter is declared as types [\"Float\"] in the docstring,\n    but the code specifies the types [\"String\"]\n    in the file manifests/init.pp near line 2.\n"

    expect {
      expect {
        PuppetModuleHelper.using_module(File.dirname(__FILE__),'test') do |tmp|
          Dir.chdir('test')
          Puppet::Face[:strings, :current].yardoc
        end
      }.to output(expected_stderr).to_stderr_from_any_process
    }.to output(expected_stout).to_stdout_from_any_process
  end
end
