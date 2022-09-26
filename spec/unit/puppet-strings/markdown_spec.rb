# frozen_string_literal: true

require 'spec_helper'
require 'puppet-strings/markdown'
require 'tempfile'

describe PuppetStrings::Markdown do
  describe 'rendering fixtures' do
    let(:fixture_path) do
      File.expand_path('../../fixtures', __dir__)
    end
    let(:output) { described_class.generate }

    def fixture_content(fixture)
      File.read(File.join(fixture_path, fixture))
    end

    def parse_shared_content
      # Populate the YARD registry with both Puppet and Ruby source
      YARD::Parser::SourceParser.parse_string(fixture_content('puppet/class.pp'), :puppet)
      YARD::Parser::SourceParser.parse_string(fixture_content('puppet/function.pp'), :puppet)
      YARD::Parser::SourceParser.parse_string(fixture_content('ruby/func4x.rb'), :ruby)
      YARD::Parser::SourceParser.parse_string(fixture_content('ruby/func4x_1.rb'), :ruby)
      YARD::Parser::SourceParser.parse_string(fixture_content('ruby/func3x.rb'), :ruby)
      YARD::Parser::SourceParser.parse_string(fixture_content('ruby/func3x.rb'), :ruby)
      YARD::Parser::SourceParser.parse_string(fixture_content('ruby/provider.rb'), :ruby)
      YARD::Parser::SourceParser.parse_string(fixture_content('ruby/resource_type.rb'), :ruby)
      YARD::Parser::SourceParser.parse_string(fixture_content('ruby/resource_api.rb'), :ruby)

      # task metadata derives the task name from the filename, so we have to parse
      # directly from the filesystem to correctly pick up the name
      YARD::Parser::SourceParser.parse(File.join(fixture_path, 'json/backup.json'))
    end

    def parse_plan_content
      # the parser behaves differently when parsing puppet files in the the plans directory,
      # so we have to parse directly from the filesystem to correctly pick up the name
      YARD::Parser::SourceParser.parse(File.join(fixture_path, 'plans/plan.pp'))
    end

    def parse_data_type_content
      YARD::Parser::SourceParser.parse_string(fixture_content('ruby/data_type.rb'), :ruby)
      YARD::Parser::SourceParser.parse_string(fixture_content('puppet/type_alias.pp'), :puppet)
    end

    RSpec.shared_examples 'markdown lint checker' do |_parameter|
      it 'does not generate markdown lint errors from the rendered markdown' do
        expect(output).to have_no_markdown_lint_errors
      end
    end

    before(:each) do
      parse_shared_content
    end

    include_examples 'markdown lint checker'

    describe 'table of contents' do
      it 'includes links to public classes' do
        expect(output).to match(%r{\[`klass`\]\(#.*\).*simple class}i)
      end

      it 'includes links to private classes' do
        expect(output).to match(%r{`noparams`.*overview.*noparams}i)
      end

      it 'includes links to defined types' do
        expect(output).to match(%r{\[`klass::dt`\]\(#.*\).*simple defined type}i)
      end

      it 'includes links to resource types' do
        expect(output).to match(%r{\[`apt_key`\]\(#.*\).*resource type.*new api}i)
        expect(output).to match(%r{\[`database`\]\(#.*\).*example database.*type}i)
      end

      it 'includes links to functions' do
        expect(output).to match(%r{\[`func`\]\(#.*\).*simple puppet function}i)
        expect(output).to match(%r{\[`func3x`\]\(#.*\).*example 3\.x function}i)
        expect(output).to match(%r{\[`func4x`\]\(#.*\).*example 4\.x function}i)
        expect(output).to match(%r{\[`func4x_1`\]\(#.*\).*example 4\.x function.*one signature}i)
      end

      it 'includes links to tasks' do
        expect(output).to match(%r{\[`backup`\]\(#.*\).*backup your database}i)
      end
    end

    describe 'resource types' do
      it 'includes checks in parameter list for the database type' do
        expect(output).to match(%r{check to see if the database already exists}i)
      end
    end

    describe 'with Puppet Plans', if: TEST_PUPPET_PLANS do
      before(:each) do
        parse_plan_content
      end

      include_examples 'markdown lint checker'

      describe 'table of contents' do
        it 'includes links to plans' do
          expect(output).to match(%r{\[`plann`\]\(#.*\).*simple plan}i)
        end
      end
    end

    describe 'with Puppet Data Types', if: TEST_PUPPET_DATATYPES do
      before(:each) do
        parse_data_type_content
      end

      include_examples 'markdown lint checker'

      describe 'table of contents' do
        it 'includes links to data types' do
          expect(output).to match(%r{\[`Amodule::ComplexAlias`\]\(#.*\).*Amodule::ComplexAlias}i)
          expect(output).to match(%r{\[`Amodule::SimpleAlias`\]\(#.*\).*Amodule::SimpleAlias}i)
          expect(output).to match(%r{\[`UnitDataType`\]\(#.*\).*data type in ruby}i)
        end
      end

      describe 'parameter docs' do
        it 'includes param name' do
          expect(output).to match(%r{#+ `param1`})
        end

        it 'includes param type' do
          expect(output).to match(%r{Data type: `Variant\[Numeric, String\[1,2\]\]`})
        end

        it 'includes param description' do
          expect(output).to match(%r{a variant parameter}i)
        end

        it 'includes param default' do
          expect(output).to match(%r{default value: `param2`}i)
        end
      end

      describe 'function docs' do
        it 'includes signature' do
          expect(output).to match(%r{UnitDataType\.func1\(param1, param2\)})
        end

        it 'includes summary' do
          expect(output).to match(%r{func1 documentation}i)
        end

        it 'includes parameter docs' do
          expect(output).to match(%r{param1 documentation}i)
        end

        it 'includes return value' do
          expect(output).to match(%r{returns: `optional\[string\]`}i)
        end
      end
    end
  end

  it 'renders only private functions correctly' do
    expect(YARD::Parser::SourceParser.parse_string(<<~'PUPPET', :puppet).enumerator.length).to eq(1)
      # @return void
      # @api private
      function func_private() {}
    PUPPET

    expect(described_class.generate).to eq(<<~'MARKDOWN')
      # Reference

      <!-- DO NOT EDIT: This document was generated by Puppet Strings -->

      ## Table of Contents

      ### Functions

      #### Private Functions

      * `func_private`

    MARKDOWN
  end

  it 'renders only public functions correctly' do
    expect(YARD::Parser::SourceParser.parse_string(<<~'PUPPET', :puppet).enumerator.length).to eq(1)
      # @return void
      function func_public() {}
    PUPPET

    expect(described_class.generate).to eq(<<~'MARKDOWN')
      # Reference

      <!-- DO NOT EDIT: This document was generated by Puppet Strings -->

      ## Table of Contents

      ### Functions

      * [`func_public`](#func_public)

      ## Functions

      ### <a name="func_public"></a>`func_public`

      Type: Puppet Language

      The func_public function.

      #### `func_public()`

      The func_public function.

      Returns: `Any` void

    MARKDOWN
  end

  it 'renders both public and private functions correctly' do
    expect(YARD::Parser::SourceParser.parse_string(<<~'PUPPET', :puppet).enumerator.length).to eq(2)
      # @return void
      function func_public() {}

      # @return void
      # @api private
      function func_private() {}
    PUPPET

    expect(described_class.generate).to eq(<<~'MARKDOWN')
      # Reference

      <!-- DO NOT EDIT: This document was generated by Puppet Strings -->

      ## Table of Contents

      ### Functions

      #### Public Functions

      * [`func_public`](#func_public)

      #### Private Functions

      * `func_private`

      ## Functions

      ### <a name="func_public"></a>`func_public`

      Type: Puppet Language

      The func_public function.

      #### `func_public()`

      The func_public function.

      Returns: `Any` void

    MARKDOWN
  end
end
