require 'spec_helper'
require 'puppetx/yardoc/pops/yard_statement'

describe Puppetx::Yardoc::Pops do
  let(:parser) {Puppet::Pops::Parser::Parser.new()}

  describe "YARDstatement class" do
    let(:manifest) {"#hello world\nclass foo { }"}
    let(:model) {parser.parse_string(manifest).current.definitions.first}
    let(:test_statement) {Puppetx::Yardoc::Pops::YARDStatement.new(model)}

    describe "when creating a new instance of YARDStatement" do
      it "should raise an error if the argument is not a PopsObject" do
        test_arg = 'foo bar'
        expect{Puppetx::Yardoc::Pops::YARDStatement.new(test_arg)}.to raise_error(ArgumentError)
      end

      it "should extract comments from the source code" do
        expect(test_statement.comments).to match(/^#hello world/)
      end
    end
  end

  describe "YARDTransfomer class" do
    let(:manifest) {"#hello world\nclass foo($bar) { }"}
    let(:manifest_default) {"#hello world\nclass foo($bar = 3) { }"}
    let(:transformer) {Puppetx::Yardoc::Pops::YARDTransformer.new}

     describe "transform method" do
       it "should perform the correct transformation with parameter defaults" do
        model = parser.parse_string(manifest_default).current.definitions.first
        statements = transformer.transform(model)
        expect(statements.parameters[0][0].class).to be(Puppetx::Yardoc::Pops::YARDStatement)
       end

       it "should perform the correct transofmration without parameter defaults" do
        model = parser.parse_string(manifest).current.definitions.first
        statements = transformer.transform(model)
        expect(statements.parameters[0][1].class).to be(NilClass)
       end
    end
  end
end
