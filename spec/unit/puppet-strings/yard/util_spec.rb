require 'spec_helper'
require 'puppet-strings/yard'

describe PuppetStrings::Yard::Util do
  subject {PuppetStrings::Yard::Util}

  describe 'scrub_string' do
    it 'should remove `%Q` and its brackets from a string ' do
      str = "%Q{this is a test string}"
      expect(subject.scrub_string(str)).to eq('this is a test string')
    end

    it 'should remove `%q` and its brackets from a string' do
      str = "%q{this is a test string}"
      expect(subject.scrub_string(str)).to eq('this is a test string')
    end

    it 'should not affect newlines when %Q notation is used' do
      str = <<-STR
%Q{this is
a test string}
STR
      expect(subject.scrub_string(str)).to eq("this is\na test string")
    end

    it 'should not affect a string which does not use %Q notation' do
      str = "this is a test string"
      expect(subject.scrub_string(str)).to eq('this is a test string')
    end
  end
end
