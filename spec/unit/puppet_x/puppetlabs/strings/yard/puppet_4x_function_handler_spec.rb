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

  it "should issue a warning if the parameter names do not match the docstring" do
      expected_output_not_a_param = "[warn]: @param tag has unknown parameter" +
        " name: not_a_param \n    in file `(stdin)' near line 3"
      expected_output_also_not_a_param = "[warn]: @param tag has unknown " +
        "parameter name: also_not_a_param \n    in file `(stdin)' near line 3"
      expect {
        parse <<-RUBY
          # @param not_a_param [Integer] the first number to be compared
          # @param also_not_a_param [Integer] the second number to be compared
          Puppet::Functions.create_function(:max) do
            def max(num_a, num_b)
              num_a >= num_b ? num_a : num_b
            end
          end
        RUBY
      }.to output("#{expected_output_not_a_param}\n#{expected_output_also_not_a_param}\n").to_stdout_from_any_process
  end

  it "should not issue a warning when the parameter names match the docstring" do
      expect {
        parse <<-RUBY
          # @param num_a [Integer] the first number to be compared
          # @param num_b [Integer] the second number to be compared
          Puppet::Functions.create_function(:max) do
            def max(num_a, num_b)
              num_a >= num_b ? num_a : num_b
            end
          end
        RUBY
      }.to output("").to_stdout_from_any_process
  end

  it "should not issue a warning when there are parametarized types and parameter names are the same" do
      expect {
        parse <<-RUBY
          # @param num_a Integer[1,2] the first number to be compared
          # @param num_b Integer[1,2] the second number to be compared
          Puppet::Functions.create_function(:max) do
            def max(num_a, num_b)
              num_a >= num_b ? num_a : num_b
            end
          end
        RUBY
      }.to output("").to_stdout_from_any_process
  end

  it "should issue a warning when there are parametarized types and parameter names differ" do
      expected_output_not_num_a = "[warn]: @param tag has unknown parameter" +
        " name: not_num_a \n    in file `(stdin)' near line 3"
      expect {
        parse <<-RUBY
          # @param not_num_a Integer[1,2] the first number to be compared
          # @param num_b Integer[1,2] the second number to be compared
          Puppet::Functions.create_function(:max) do
            dispatch max_1 do
              param 'Integer[1,2]', :num_a
              param 'Integer[1,2]', :num_b
            end

            def max_1(num_a, num_b)
              num_a >= num_b ? num_a : num_b
            end
          end
        RUBY
      }.to output("#{expected_output_not_num_a}\n").to_stdout_from_any_process
  end


  it "should issue a warning if the parameter names do not match the docstring in dispatch method" do
      expected_output_not_a_param = "[warn]: @param tag has unknown parameter" +
        " name: not_a_param \n    in file `(stdin)' near line 3"
      expected_output_also_not_a_param = "[warn]: @param tag has unknown " +
        "parameter name: also_not_a_param \n    in file `(stdin)' near line 3"
      expect {
        parse <<-RUBY
          # @param not_a_param [Integer] the first number to be compared
          # @param also_not_a_param [Integer] the second number to be compared
          Puppet::Functions.create_function(:max) do
            dispatch max_1 do
              param 'Integer[1,2]', :num_a
              param 'Integer', :num_b
            end

            dispatch max_2 {
              param 'String', :num_c
              param 'String[1,2]', :num_d
            }

            def max_1(num_a, num_b)
              num_a >= num_b ? num_a : num_b
            end

            def max_2(num_a, num_b)
              num_a >= num_b ? num_a : num_b
            end
          end
        RUBY
      }.to output("#{expected_output_not_a_param}\n#{expected_output_also_not_a_param}\n").to_stdout_from_any_process
  end

  it "should not issue a warning if the parameter names do match the " +
        "docstring in dispatch method" do
      expect {
        parse <<-RUBY
          # @param [Integer] num_a the first number to be compared
          # @param num_b [Integer] the second number to be compared
          Puppet::Functions.create_function(:max) do
            dispatch max_1 do
              param 'Integer', :num_a
              param 'Integer', :num_b
            end

            def max_1(num_a, num_b)
              num_a >= num_b ? num_a : num_b
            end
          end
        RUBY
      }.to output("").to_stdout_from_any_process
  end
end
