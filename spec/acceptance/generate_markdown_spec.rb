require 'spec_helper_acceptance'
require 'util'

include PuppetStrings::Acceptance::Util

describe 'Generating Markdown' do
  expected = <<-EOF
# Reference

## Classes
* [`test`](#test): This class exists to serve as fixture data for testing the puppet strings face

## Classes

### test

#### Examples
```puppet
class { "test": }
```

#### Parameters

##### `package_name`

The name of the package

##### `service_name`

The name of the service

  EOF

  it 'should render Markdown to stdout when using --format markdown and --stdout' do
    test_module_path = get_test_module_path(master, /Module test/)
    on master, puppet('strings', 'generate', '--format markdown', "#{test_module_path}/manifests/init.pp") do
      output = stdout.chomp
      expect(JSON.parse(output)).to eq(expected)
    end
  end

  it 'should write Markdown to a file when using --format markdown and --out' do
    test_module_path = get_test_module_path(master, /Module test/)
    tmpfile = master.tmpfile('md_output.md')
    on master, puppet('strings', 'generate', '--format markdown', "--out #{tmpfile}", "#{test_module_path}/manifests/init.pp")
    output = read_file_on(master, tmpfile)
    expect(JSON.parse(output)).to eq(expected)
  end
end
