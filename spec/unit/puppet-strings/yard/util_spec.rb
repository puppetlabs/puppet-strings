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

  describe 'github_to_yard_links' do
    it 'converts a link correctly' do
      str = '<a href="#module-description">'
      expect(subject.github_to_yard_links(str)).to eq('<a href="#label-Module+description">')
    end

    it 'leaves other links with hashes alone' do
      str = '<a href="www.github.com/blah/document.html#module-description">'
      expect(subject.github_to_yard_links(str)).to eq(str)
    end

    it 'leaves plain text alone' do
      str = '<a href="#module-description"> module-description'
      expect(subject.github_to_yard_links(str)).to eq('<a href="#label-Module+description"> module-description')
    end
  end
end
