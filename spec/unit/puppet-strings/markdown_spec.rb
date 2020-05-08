require 'spec_helper'
require 'puppet-strings/markdown'
require 'puppet-strings/markdown/table_of_contents'
require 'tempfile'

describe PuppetStrings::Markdown do
  let(:fixture_path) do
    File.expand_path("../../fixtures", __dir__)
  end

  def fixture_content(fixture)
    @fixtures ||= {}
    @fixtures[fixture] ||= File.read(File.join(fixture_path, fixture))
  end

  def parse_shared_content
    # Populate the YARD registry with both Puppet and Ruby source
    YARD::Parser::SourceParser.parse_string(fixture_content("puppet/class.pp"), :puppet)
    YARD::Parser::SourceParser.parse_string(fixture_content("puppet/function.pp"), :puppet)
    YARD::Parser::SourceParser.parse_string(fixture_content("ruby/func4x.rb"), :ruby)
    YARD::Parser::SourceParser.parse_string(fixture_content("ruby/func4x_1.rb"), :ruby)
    YARD::Parser::SourceParser.parse_string(fixture_content("ruby/func3x.rb"), :ruby)
    YARD::Parser::SourceParser.parse_string(fixture_content("ruby/func3x.rb"), :ruby)
    YARD::Parser::SourceParser.parse_string(fixture_content("ruby/provider.rb"), :ruby)
    YARD::Parser::SourceParser.parse_string(fixture_content("ruby/resource_type.rb"), :ruby)
    YARD::Parser::SourceParser.parse_string(fixture_content("ruby/resource_api.rb"), :ruby)

    # task metadata derives the task name from the filename, so we have to parse
    # directly from the filesystem to correctly pick up the name
    YARD::Parser::SourceParser.parse(File.join(fixture_path, "json/backup.json"))
  end

  def parse_plan_content
    YARD::Parser::SourceParser.parse_string(fixture_content("puppet/plan.pp"), :puppet)
  end

  def parse_data_type_content
    YARD::Parser::SourceParser.parse_string(fixture_content("ruby/data_type.rb"), :ruby)
    YARD::Parser::SourceParser.parse_string(fixture_content("puppet/type_alias.pp"), :puppet)
  end

  let(:baseline_path) { File.join(File.dirname(__FILE__), "../../fixtures/unit/markdown/#{filename}") }
  let(:baseline) { File.read(baseline_path) }

  RSpec.shared_examples 'markdown lint checker' do |parameter|
    it 'should not generate markdown lint errors from the rendered markdown', if: mdl_available do
      pending('Failures are expected')
      Tempfile.open('md') do |file|
        PuppetStrings::Markdown.render(file.path)

        expect(File.read(file.path)).to have_no_markdown_lint_errors
      end
    end
  end

  describe 'rendering markdown to a file' do
    before(:each) do
      parse_shared_content
    end

    context 'with common Puppet and ruby content' do
      let(:filename) { 'output.md' }

      it 'should output the expected markdown content' do
        Tempfile.open('md') do |file|
          PuppetStrings::Markdown.render(file.path)
          expect(File.read(file.path)).to eq(baseline)
        end
      end

      include_examples 'markdown lint checker'
    end

    describe 'with Puppet Plans', :if => TEST_PUPPET_PLANS do
      let(:filename) { 'output_with_plan.md' }

      before(:each) do
        parse_plan_content
      end

      it 'should output the expected markdown content' do
        Tempfile.open('md') do |file|
          PuppetStrings::Markdown.render(file.path)
          expect(File.read(file.path)).to eq(baseline)
        end
      end

      include_examples 'markdown lint checker'
    end

    describe 'with Puppet Data Types', :if => TEST_PUPPET_DATATYPES do
      let(:filename) { 'output_with_data_types.md' }

      before(:each) do
        parse_data_type_content
      end

      it 'should output the expected markdown content' do
        Tempfile.open('md') do |file|
          PuppetStrings::Markdown.render(file.path)
          expect(File.read(file.path)).to eq(baseline)
        end
      end

      include_examples 'markdown lint checker'
    end
  end
end
