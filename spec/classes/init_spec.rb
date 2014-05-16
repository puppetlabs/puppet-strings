require 'spec_helper'
describe 'puppet_yardoc' do

  context 'with defaults for all parameters' do
    it { should contain_class('puppet_yardoc') }
  end
end
