require 'spec_helper'
require 'puppet/face/strings'
require 'tmpdir'
require 'stringio'

describe Puppet::Face do

  describe "YARDoc action" do
    it "should raise an error if yard is absent" do
      Puppet.features.stubs(:yard?).returns(false)
      expect{Puppet::Face[:strings, :current].yardoc}.to raise_error(RuntimeError, "The 'yard' gem must be installed in order to use this face.")
    end

    it "should raise an error if rgen is absent" do
      Puppet.features.stubs(:rgen?).returns(false)
      expect{Puppet::Face[:strings, :current].yardoc}.to raise_error(RuntimeError, "The 'rgen' gem must be installed in order to use this face.")
    end

    it "should raise an error if the Ruby verion is less than 1.9", :if => RUBY_VERSION.match(/^1\.8/) do
      expect{Puppet::Face[:strings, :current].yardoc}.to raise_error(RuntimeError, "This face requires Ruby 1.9 or greater.")
    end

    it "should invoke Yardoc with MODULE_SOURCEFILES if no arguments are provided" do
      YARD::CLI::Yardoc.expects(:run).with('manifests/**/*.pp', 'lib/**/*.rb')
      Puppet::Face[:strings, :current].yardoc
    end

    it "should invoke Yardoc with provided arguments" do
      YARD::CLI::Yardoc.expects(:run).with('--debug', 'some_file.rb')
      Puppet::Face[:strings, :current].yardoc('--debug', 'some_file.rb')
    end

    describe "when generating HTML for documentation" do

      # HACK: In these tests we would like to suppress all output from the yard
      # logger so we don't clutter up stdout.
      # However, we do want the yard logger for other tests so we can
      # assert that the right things are logged. To accomplish this, for
      # this block of tests we monkeypatch the yard logger to be a generic
      # stringio instance which does nothing and then we restore the
      # original afterwards.
      before(:all) do
        @tmp = YARD::Logger.instance.io
        YARD::Logger.instance.io = StringIO.new
      end

      after(:all) do
        YARD::Logger.instance.io = @tmp
      end

      it "should properly generate HTML for manifest comments" do


        using_module('test') do |tmp|
          Dir.chdir('test')

          Puppet::Face[:strings, :current].yardoc

          expect(read_html(tmp, 'test', 'test.html')).to include("Class: test")
        end
      end

      it "should properly generate HTML for 3x function comments" do
        using_module('test') do |tmp|
          Dir.chdir('test')

          Puppet::Face[:strings, :current].yardoc

          expect(read_html(tmp, 'test', 'Puppet3xFunctions.html')).to include("This is the function documentation for `function3x`")
        end
      end

      it "should properly generate HTML for 4x function comments" do
        using_module('test') do |tmp|
          Dir.chdir('test')

          Puppet::Face[:strings, :current].yardoc

          expect(read_html(tmp, 'test', 'Puppet4xFunctions.html')).to include("This is a function which is used to test puppet strings")
        end
      end
    end
  end

  describe "server action" do
    it "should raise an error if yard is absent" do
      Puppet.features.stubs(:yard?).returns(false)
      expect{Puppet::Face[:strings, :current].server}.to raise_error(RuntimeError, "The 'yard' gem must be installed in order to use this face.")
    end

    it "should raise an error if rgen is absent" do
      Puppet.features.stubs(:rgen?).returns(false)
      expect{Puppet::Face[:strings, :current].server}.to raise_error(RuntimeError, "The 'rgen' gem must be installed in order to use this face.")
    end

    it "should raise an error if the Ruby version is less than 1.9", :if => RUBY_VERSION.match(/^1\.8/) do
      expect{Puppet::Face[:strings, :current].server}.to raise_error(RuntimeError, "This face requires Ruby 1.9 or greater.")
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

