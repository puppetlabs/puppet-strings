require 'spec_helper'
require 'puppetx/yardoc/yard/handlers'

describe Puppetx::Yardoc::YARD::Handlers do
  describe "DefinedTypeHanlder" do
    it "should add a defined type object in the Registry" do
      parse_file :defined_type, __FILE__, log.level, '.pp'
      obj = Registry.at("wibbly::wobbly")
      expect(obj.type).to be(:definedtype)
    end
  end

  describe "FutureParserDispatchHandler" do
    before(:each) {parse_file :puppet4_function, __FILE__, log.level, '.rb'}

    it "should add a puppet namespace object to the Registry" do
      namespace = Registry.at("FutureParserFunctions")
      expect(namespace.type).to be(:puppetnamespace)
    end

    it "should add a future parser function object to the Registry" do
      function = Registry.at("FutureParserFunctions#puppet4_function")
      expect(function.type).to be(:method)
    end

    it "should add a method object to the Registry" do
      method = Registry.at("#puppet4_function")
      expect(method.type).to be(:method)
    end
  end

  describe "ParserFunctionHanlder" do
    before(:each) {parse_file :puppet3_function, __FILE__, log.level, '.rb'}

    it "should add a module object to the Registry" do
      puppet_module = Registry.at("Puppet::Parser::Functions")
      expect(puppet_module.type).to be(:module)
    end

    it "should add a puppet namespace object to the Registry" do
      namespace = Registry.at("ParserFunctions")
      expect(namespace.type).to be(:puppetnamespace)
    end

    it "should add a method object to the Registry" do
      method = Registry.at("ParserFunctions#puppet3_function")
      expect(method.type).to be(:method)
    end
  end

  describe "HostClassDefintion" do
    before(:each) {parse_file :class, __FILE__, log.level, '.pp'}
    it "should add a host class object to the Registry" do
      hostclass = Registry.at("foo::bar")
      expect(hostclass.type).to be(:hostclass)
    end
  end
end
