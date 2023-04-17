# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'Generating Markdown' do
  let(:test_module_path) do
    sut_module_path(/Module test/)
  end

  let(:remote_tmp_path) do
    sut_tmp_path
  end

  expected = <<~EOF
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

  it 'renders Markdown to stdout when using --format markdown' do
    skip('This test is broken. Does not output to STDOUT by default.')
    output = PuppetLitmus::PuppetHelpers.run_shell("puppet strings generate --format markdown \"#{test_module_path}/manifests/init.pp\"").stdout.chomp
    expect(output).to eq(expected)
  end

  it 'writes Markdown to a file when using --format markdown and --out' do
    tmpfile = File.join(remote_tmp_path, 'md_output.md')
    PuppetLitmus::PuppetHelpers.run_shell("puppet strings generate --format markdown --out \"#{tmpfile}\" \"#{test_module_path}/manifests/init.pp\"")
    expect(file(tmpfile)).to contain expected
  end
end
