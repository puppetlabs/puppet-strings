require 'spec_helper_acceptance'
require 'json'

describe 'Genearting module documation using yardoc action' do
  def read_file_on(host, filename)
    on(host, "cat #{filename}").stdout
  end

  before :all do
    modules = JSON.parse(on(master, puppet("module", "list", "--render-as", "json")).stdout)
    test_module_info = modules["modules_by_path"].values.flatten.find { |mod_info| mod_info =~ /Module test/ }
    test_module_path = test_module_info.match(/\(([^)]*)\)/)[1]

    on master, puppet("strings", "#{test_module_path}/**/*.{rb,pp}")
  end

  it "should generate documentation for manifests" do
    expect(read_file_on(master, '/root/doc/test.html')).to include("Class: test")
  end

  it "should generate documenation for 3x functions" do
    expect(read_file_on(master, '/root/doc/Puppet3xFunctions.html')).to include("This is the function documentation for `function3x`")
  end

  it "should generate documenation for 4x functions" do
    expect(read_file_on(master, '/root/doc/Puppet4xFunctions.html')).to include("This is a function which is used to test puppet strings")
  end
end
