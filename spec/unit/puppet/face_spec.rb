require 'spec_helper'
require 'puppet/face/yardoc'

describe Puppet::Face do

  describe "YARDoc action" do
    it "should raise an error if yard is absent" do
      Puppet.features.stubs(:yard?).returns(false)
      expect{Puppet::Face[:yardoc, :current].yardoc}.to raise_error(RuntimeError, "The 'yard' gem must be installed in order to use this face.")
    end

    it "should raise an error if rgen is absent" do
      Puppet.features.stubs(:rgen?).returns(false)
      expect{Puppet::Face[:yardoc, :current].yardoc}.to raise_error(RuntimeError, "The 'rgen' gem must be installed in order to use this face.")
    end

    it "should raise an error if the Ruby verion is less than 1.9", :if => RUBY_VERSION.match(/^1\.8/) do
      expect{Puppet::Face[:yardoc, :current].yardoc}.to raise_error(RuntimeError, "This face requires Ruby 1.9 or greater.")
    end

    it "should invoke Yardoc with MODULE_SOURCEFILES if no arguments are provided" do
      YARD::CLI::Yardoc.expects(:run).with('manifests/**/*.pp', 'lib/**/*.rb')
      Puppet::Face[:yardoc, :current].yardoc
    end

    it "should invoke Yardoc with provided arguments" do
      YARD::CLI::Yardoc.expects(:run).with('--debug', 'some_file.rb')
      Puppet::Face[:yardoc, :current].yardoc('--debug', 'some_file.rb')
    end
  end

  describe "modules action" do
    it "should raise an error if yard is absent" do
      Puppet.features.stubs(:yard?).returns(false)
      expect{Puppet::Face[:yardoc, :current].modules}.to raise_error(RuntimeError, "The 'yard' gem must be installed in order to use this face.")
    end

    it "should raise an error if rgen is absent" do
      Puppet.features.stubs(:rgen?).returns(false)
      expect{Puppet::Face[:yardoc, :current].modules}.to raise_error(RuntimeError, "The 'rgen' gem must be installed in order to use this face.")
    end

    it "should raise an error if the Ruby version is less than 1.9", :if => RUBY_VERSION.match(/^1\.8/) do
      expect{Puppet::Face[:yardoc, :current].modules}.to raise_error(RuntimeError, "This face requires Ruby 1.9 or greater.")
    end
  end

  describe "server action" do
    it "should raise an error if yard is absent" do
      Puppet.features.stubs(:yard?).returns(false)
      expect{Puppet::Face[:yardoc, :current].server}.to raise_error(RuntimeError, "The 'yard' gem must be installed in order to use this face.")
    end

    it "should raise an error if rgen is absent" do
      Puppet.features.stubs(:rgen?).returns(false)
      expect{Puppet::Face[:yardoc, :current].server}.to raise_error(RuntimeError, "The 'rgen' gem must be installed in order to use this face.")
    end

    it "should raise an error if the Ruby version is less than 1.9", :if => RUBY_VERSION.match(/^1\.8/) do
      expect{Puppet::Face[:yardoc, :current].server}.to raise_error(RuntimeError, "This face requires Ruby 1.9 or greater.")
    end
  end
end
