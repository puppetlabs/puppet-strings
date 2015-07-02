require 'spec_helper'
require 'puppet_x/puppetlabs/strings/yard/templates/default/template_helper'
require 'puppet_x/puppetlabs/strings/yard/code_objects/puppet_namespace_object'
require 'strings_spec/parsing'

describe TemplateHelper do
  it "should not print any warning if the tags and parameters match" do
    th = TemplateHelper.new

    # Case 0: If the documented tags do include the parameter,
    # nothing is printed
    tag0 = YARD::Tags::Tag.new(:param, 'a_parameter')
    tag0.name = 'a_parameter'
    obj0 = PuppetX::PuppetLabs::Strings::YARD::CodeObjects::PuppetNamespaceObject.new(:root, 'Puppet3xFunctions')
    obj0.add_tag tag0
    obj0.parameters = [['a_parameter']]
    expect { th.check_parameters_match_docs obj0 }.to output("").to_stderr_from_any_process

    # The docstring is still alive between tests. Clear the tags registered with
    # it so the tags won't persist between tests.
    obj0.docstring.instance_variable_set("@tags", [])
  end

  it "should print the warning with no location data if the tags and " +
      "parameters differ and the location data is not properly formed" do
    th = TemplateHelper.new
    # Case 1: If the parameter and tag differ and the location is not properly
    # formed, print out the warning with no location data
    tag1 = YARD::Tags::Tag.new(:param, 'aa_parameter')
    tag1.name = 'aa_parameter'
    obj1 = PuppetX::PuppetLabs::Strings::YARD::CodeObjects::PuppetNamespaceObject.new(:root, 'Puppet3xFunctions')
    obj1.add_tag tag1
    obj1.parameters = [['b_parameter']]
    expect { th.check_parameters_match_docs obj1 }.to output("[warn]: The parameter aa_parameter is documented, but doesn't exist in your code. Sorry, the file and line number could not be determined.\n").to_stderr_from_any_process

    # The docstring is still alive between tests. Clear the tags registered with
    # it so the tags won't persist between tests.
    obj1.docstring.instance_variable_set("@tags", [])
  end

  it "should print the warning with location data if the tags and parameters " +
      "differ and the location data is properly formed" do
    th = TemplateHelper.new
    # Case 2: If the parameter and tag differ and the location is properly
    # formed, print out the warning with no location data
    tag2 = YARD::Tags::Tag.new(:param, 'aaa_parameter')
    tag2.name = 'aaa_parameter'
    obj2 = PuppetX::PuppetLabs::Strings::YARD::CodeObjects::PuppetNamespaceObject.new(:root, 'Puppet3xFunctions')
    obj2.files = [['some_file.pp', 42]]
    obj2.add_tag tag2
    obj2.parameters = [['b_parameter']]
    expect { th.check_parameters_match_docs obj2 }.to output("[warn]: The parameter aaa_parameter is documented, but doesn't exist in your code, in file some_file.pp near line 42\n").to_stderr_from_any_process

    # The docstring is still alive between tests. Clear the tags registered with
    # it so the tags won't persist between tests.
    obj2.docstring.instance_variable_set("@tags", [])
  end

end
