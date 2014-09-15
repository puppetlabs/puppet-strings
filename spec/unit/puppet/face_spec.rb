require 'spec_helper'
require 'puppet/face/yardoc'
require 'rspec-html-matchers'
require 'tmpdir'
require 'stringio'

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

    describe "when generating HTML for documentation" do
      it "should properly generate HTML for manifest comments" do

        YARD::Logger.instance.io = StringIO.new

        using_module('test') do |tmp|
          Dir.chdir('test')

          Puppet::Face[:yardoc, :current].yardoc

          expect(read_html(tmp, 'test', 'test.html')).to have_tag('.docstring .discussion', :text => /This class/)
        end
      end

      it "should properly generate HTML for 3x function comments" do
        using_module('test') do |tmp|
          Dir.chdir('test')

          Puppet::Face[:yardoc, :current].yardoc

          expect(read_html(tmp, 'test', 'ParserFunctions.html')).to have_tag('.docstring .discussion', :text => /documentation for `function3x`/)
        end
      end

      it "should properly generate HTML for 4x function comments" do
        using_module('test') do |tmp|
          Dir.chdir('test')

          Puppet::Face[:yardoc, :current].yardoc

          expect(read_html(tmp, 'test', 'test.html')).to have_tag('.docstring .discussion', :text => /This class/)
        end
      end
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

  # Helper methods to handle file operations around generating and loading HTML
  def using_module(modulename, &block)
    Dir.mktmpdir do |tmp|
      module_location = File.join(File.dirname(__FILE__), "examples", modulename)
      FileUtils.cp_r(module_location, tmp)
      old_dir = Dir.pwd
      begin
        Dir.chdir(tmp)
        yield(tmp)
      ensure
        Dir.chdir(old_dir)
      end
    end
  end

  def read_html(dir, modulename, file)
    File.read(File.join(dir, modulename, 'doc', file))
  end
end
