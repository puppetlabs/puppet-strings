require 'spec_helper_acceptance'

describe 'Generating Markdown' do
  before(:all) do
    @test_module_path = sut_module_path(/Module test/)
    @remote_tmp_path = sut_tmp_path
  end

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

  it 'should render Markdown to stdout when using --format markdown' do
    skip('This test is broken. Does not output to STDOUT by default.')
    output = PuppetLitmus::Serverspec.run_shell("puppet strings generate --format markdown \"#{@test_module_path}/manifests/init.pp\"").stdout.chomp
    expect(output).to eq(expected)
  end

  it 'should write Markdown to a file when using --format markdown and --out' do
    tmpfile = File.join(@remote_tmp_path, 'md_output.md')
    remote = PuppetLitmus::Serverspec.run_shell("puppet strings generate --format markdown --out \"#{tmpfile}\" \"#{@test_module_path}/manifests/init.pp\"")
    expect(file(tmpfile)).to contain expected
  end
end
