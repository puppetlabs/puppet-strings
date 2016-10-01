require 'spec_helper_acceptance'
require 'util'
require 'json'

include PuppetStrings::Acceptance::Util

describe 'Generating module documentation using generate action' do
  before :all do
    test_module_path = get_test_module_path(master, /Module test/)
    on master, puppet('strings', 'generate', "#{test_module_path}/**/*.{rb,pp}")
  end

  it 'should generate documentation for manifests' do
    expect(read_file_on(master, '/root/doc/puppet_classes/test.html')).to include('Class: test')
  end

  it 'should generate documentation for 3x functions' do
    expect(read_file_on(master, '/root/doc/puppet_functions_ruby3x/function3x.html')).to include('This is the function documentation for <code>function3x</code>')
  end

  it 'should generate documentation for 4x functions' do
    expect(read_file_on(master, '/root/doc/puppet_functions_ruby4x/function4x.html')).to include('This is a function which is used to test puppet strings')
  end
end
