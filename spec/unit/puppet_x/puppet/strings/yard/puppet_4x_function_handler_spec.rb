require 'spec_helper'
require 'lib/strings_spec/module_helper'
require 'puppet_x/puppet/strings/yard/handlers/puppet_4x_function_handler'
require 'puppet/face/strings'
require 'strings_spec/parsing'

describe PuppetX::Puppet::Strings::YARD::Handlers::Puppet4xFunctionHandler do
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

  it "should issue a warning if the parameter names do not match the docstring" do
      expected_output_not_a_param = "[warn]: The parameter not_a_param is documented, but doesn't exist in\n    your code, in file lib/test.rb near line 3."
      expected_output_also_not_a_param = "[warn]: The parameter also_not_a_param is documented, but doesn't exist in\n    your code, in file lib/test.rb near line 3."
      expect {
        expect {
          PuppetModuleHelper.using_module(File.dirname(__FILE__),'test-param-names-differ') do |tmp|
            Dir.chdir('test-param-names-differ')
            Puppet::Face[:strings, :current].yardoc
          end
        }.to output(/documented/).to_stdout_from_any_process
      }.to output("#{expected_output_not_a_param}\n#{expected_output_also_not_a_param}\n").to_stderr_from_any_process
  end

  it "should not issue a warning when the parameter names match the docstring" do
      expected = ""
      expect {
        expect {
          PuppetModuleHelper.using_module(File.dirname(__FILE__),'test-param-names-match') do |tmp|
            Dir.chdir('test-param-names-match')
            Puppet::Face[:strings, :current].yardoc
          end
        }.to output(/documented/).to_stdout_from_any_process
      }.to output(expected).to_stderr_from_any_process

  end
  it "should not issue a warning when there are parametarized types and parameter names are the same" do
      expected = ""
      expect {
        expect {
          PuppetModuleHelper.using_module(File.dirname(__FILE__),'test-param-names-match-with-types') do |tmp|
            Dir.chdir('test-param-names-match-with-types')
            Puppet::Face[:strings, :current].yardoc
          end
        }.to output(/documented/).to_stdout_from_any_process
      }.to output(expected).to_stderr_from_any_process
  end

  it "should issue a warning when there are parametarized types and parameter names differ" do
      expected_output_not_num_a = "[warn]: @param tag has unknown parameter" +
        " name: not_num_a \n    in file `(stdin)' near line 3."
      expected_output_not_a_param = "[warn]: The parameter not_a_param is documented, but doesn't exist in\n    your code, in file lib/test.rb near line 3."
      expected_output_also_not_a_param = "[warn]: The parameter also_not_a_param is documented, but doesn't exist in\n    your code, in file lib/test.rb near line 3."
      expect {
        expect {
          PuppetModuleHelper.using_module(File.dirname(__FILE__),'test-param-names-differ-with-types') do |tmp|
            Dir.chdir('test-param-names-differ-with-types')
            Puppet::Face[:strings, :current].yardoc
          end
        }.to output(/documented/).to_stdout_from_any_process
      }.to output("#{expected_output_not_a_param}\n#{expected_output_also_not_a_param}\n").to_stderr_from_any_process
  end


  it "should issue a warning if the parameter names do not match the docstring in dispatch method" do
      expected_output_not_a_param = "[warn]: The parameter not_a_param is documented, but doesn't exist in\n    your code, in file lib/test.rb near line 3."
      expected_output_also_not_a_param = "[warn]: The parameter also_not_a_param is documented, but doesn't exist in\n    your code, in file lib/test.rb near line 3."
      expect {
        expect {
          PuppetModuleHelper.using_module(File.dirname(__FILE__),'test-param-names-differ-with-dispatch') do |tmp|
            Dir.chdir('test-param-names-differ-with-dispatch')
            Puppet::Face[:strings, :current].yardoc
          end
        }.to output(/documented/).to_stdout_from_any_process
      }.to output("#{expected_output_not_a_param}\n#{expected_output_also_not_a_param}\n").to_stderr_from_any_process
  end

  it "should not issue a warning if the parameter names do match the " +
        "docstring in dispatch method" do
      expected = ""
      expect {
        expect {
          PuppetModuleHelper.using_module(File.dirname(__FILE__),'test-param-names-match-with-dispatch') do |tmp|
            Dir.chdir('test-param-names-match-with-dispatch')
            Puppet::Face[:strings, :current].yardoc
          end
        }.to output(/documented/).to_stdout_from_any_process
      }.to output(expected).to_stderr_from_any_process
  end

  it "should parse unusually named functions" do
    # This should not raise a ParseErrorWithIssue exceptoin
    parse <<-RUBY
      Puppet::Functions.create_function :'max' do
        def max(num_a, num_b)
          num_a >= num_b ? num_a : num_b
        end
      end
    RUBY
  end


end
