# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'Generating JSON' do
  let(:test_module_path) do
    sut_module_path(%r{Module test})
  end

  let(:remote_tmp_path) do
    sut_tmp_path
  end

  let(:expected) do
    {
      'puppet_classes' => [],
      'data_types' => [],
      'data_type_aliases' => [],
      'defined_types' => [],
      'resource_types' => [],
      'providers' => [],
      'puppet_functions' => [
        'name' => 'function3x',
        'file' => "#{test_module_path}/lib/puppet/parser/functions/function3x.rb",
        'line' => 3,
        'type' => 'ruby3x',
        'signatures' => [
          {
            'signature' => 'function3x()',
            'docstring' => {
              'text' => 'This is the function documentation for `function3x`',
              'tags' => [
                {
                  'tag_name' => 'return',
                  'text' => '',
                  'types' => ['Any']
                },
              ]
            }
          },
        ],
        'docstring' => {
          'text' => 'This is the function documentation for `function3x`',
          'tags' => ['tag_name' => 'return', 'text' => '', 'types' => ['Any']]
        },
          'source' => "Puppet::Parser::Functions.newfunction(:function3x, :doc => \"This is the function documentation for `function3x`\") do |args|\nend",
      ],
      'puppet_tasks' => [],
      'puppet_plans' => []
    }
  end

  it 'renders JSON to stdout when using --format json' do
    output = run_shell("puppet strings generate --format json \"#{test_module_path}/lib/puppet/parser/functions/function3x.rb\"").stdout.chomp
    expect(JSON.parse(output)).to eq(expected)
  end

  it 'writes JSON to a file when using --format json --out' do
    tmpfile = File.join(remote_tmp_path, 'json_output.json')
    run_shell("puppet strings generate --format json --out #{tmpfile} \"#{test_module_path}/lib/puppet/parser/functions/function3x.rb\"")
    expect(JSON.parse(file(tmpfile).content)).to eq(expected)
  end
end
