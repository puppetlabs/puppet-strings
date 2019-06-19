require 'spec_helper'

describe PuppetStrings::Markdown::Base do
  context 'basic class' do
    before :each do
      YARD::Parser::SourceParser.parse_string(<<-SOURCE, :puppet)
# An overview
# @api private
# @summary A simple class.
# @param param1 First param.
# @param param2 Second param.
# @param param3 Third param.
class klass(Integer $param1, $param2, String $param3 = hi) inherits foo::bar {
}
      SOURCE
    end

    let(:reg) { YARD::Registry.all(:puppet_class).sort_by!(&:name).map!(&:to_hash)[0] }
    let(:component) { PuppetStrings::Markdown::Base.new(reg, 'class') }

    describe '#name' do
      it 'returns the expected name' do
        expect(component.name).to eq 'klass'
      end
    end

    ['examples',
      'see',
      'since',
      'return_val',
      'return_type',].each do |method|
      describe "##{method}" do
        it 'returns nil' do
          expect(component.method(method.to_sym).call).to be_nil
        end
      end

    end

    describe '#private?' do
      it do
        expect(component.private?).to be true
      end
    end

    describe '#params' do
      it 'returns the expected params' do
        expect(component.params.size).to eq 3
      end
    end

    describe '#summary' do
      it 'returns the expected summary' do
        expect(component.summary).to eq 'A simple class.'
      end
    end

    describe '#toc_info' do
      let(:toc) { component.toc_info }
      it 'returns a hash' do
        expect(toc).to be_instance_of Hash
      end
      it 'prefers the summary for :desc' do
        expect(toc[:desc]).to eq 'A simple class.'
      end
    end
  end
  context 'less basic class' do
    before :each do
      YARD::Parser::SourceParser.parse_string(<<-SOURCE, :puppet)
# An overview
# It's a longer overview
# Ya know?
# @example A simple example.
#  class { 'klass::yeah':
#    param1 => 1,
#  }
# @param param1 First param.
# @param param2 Second param.
# @param param3 Third param.
class klass::yeah(
  Integer $param1,
  $param2,
  String $param3 = hi
) inherits foo::bar {

}
      SOURCE
    end

    let(:reg) { YARD::Registry.all(:puppet_class).sort_by!(&:name).map!(&:to_hash)[0] }
    let(:component) { PuppetStrings::Markdown::Base.new(reg, 'class') }

    describe '#name' do
      it 'returns the expected name' do
        expect(component.name).to eq 'klass::yeah'
      end
    end

    ['summary',
      'see',
      'since',
      'return_val',
      'return_type'].each do |method|
      describe "##{method}" do
        it 'returns nil' do
          expect(component.method(method.to_sym).call).to be_nil
        end
      end
    end

    describe '#examples' do
      it 'should return one example' do
        expect(component.examples.size).to eq 1
      end
    end

    describe '#params' do
      it 'returns the expected params' do
        expect(component.params.size).to eq 3
      end
    end

    describe '#private?' do
      it do
        expect(component.private?).to be false
      end
    end

    describe '#toc_info' do
      let(:toc) { component.toc_info }
      it 'returns a hash' do
        expect(toc).to be_instance_of Hash
      end
      it 'uses overview for :desc in absence of summary' do
        expect(toc[:desc]).to eq 'An overview It\'s a longer overview Ya know?'
      end
    end

    describe '#link' do
      it 'returns a valid link' do
        expect(component.link).to eq 'klassyeah'
      end
    end
  end
end
