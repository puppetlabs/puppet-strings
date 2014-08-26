require 'spec_helper'
require 'puppetx/yardoc/yard/handlers'

describe Puppetx::Yardoc::YARD::Handlers do
  describe "DefinedTypeHanlder" do
    it "should add a defined type object in the Registry" do
      parse_file :defined_type, __FILE__
      require 'pry'
      #binding.pry
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
end
