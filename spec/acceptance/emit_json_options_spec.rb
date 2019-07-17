require 'spec_helper_acceptance'

describe 'Emitting JSON' do
  before(:all) do
    @test_module_path = sut_module_path(/Module test/)
    @remote_tmp_path = sut_tmp_path
  end

  let(:expected) do
    {
      "puppet_classes" => [],
      "data_types" => [],
      "data_type_aliases" => [],
      "defined_types" => [],
      "resource_types" => [],
      "providers" => [],
      "puppet_functions" => [
        "name" => "function3x",
        "file" => "#{@test_module_path}/lib/puppet/parser/functions/function3x.rb",
        "line" => 1,
        "type" => "ruby3x",
        "signatures" => [
          {
            "signature" =>"function3x()",
            "docstring" => {
              "text" => "This is the function documentation for `function3x`",
              "tags" => [
                {
                  "tag_name"=>"return",
                  "text"=>"",
                  "types"=>["Any"]
                }
              ]
            }
          },
        ],
        "docstring" => {
          "text" => "This is the function documentation for `function3x`",
          "tags" => ["tag_name" => "return", "text" => "", "types" => ["Any"]]},
          "source" => "Puppet::Parser::Functions.newfunction(:function3x, :doc => \"This is the function documentation for `function3x`\") do |args|\nend"
      ],
      "puppet_tasks" => [],
      "puppet_plans" => []
    }
  end

  [
    { :title => '--format json and STDOUT', :cmd_line => '--format json' },
    { :title => '--emit-json-stdout', :cmd_line => '--emit-json-stdout' }
  ].each do |testcase|
    it "should emit JSON to stdout when using #{testcase[:title]}" do
      output = PuppetLitmus::Serverspec.run_shell("puppet strings generate #{testcase[:cmd_line]} \"#{@test_module_path}/lib/puppet/parser/functions/function3x.rb\"").stdout.chomp
      expect(JSON.parse(output)).to eq(expected)
    end
  end

  [
    { :title => '--format json and --out', :cmd_line => '--format json --out "TMPFILE"' },
    { :title => '--emit-json', :cmd_line => '--emit-json "TMPFILE"' },
  ].each do |testcase|
    it "should write JSON to a file when using #{testcase[:title]}" do
      tmpfile = File.join(@remote_tmp_path, 'json_output.json')
      cmd = "puppet strings generate #{testcase[:cmd_line].gsub('TMPFILE', tmpfile)} \"#{@test_module_path}/lib/puppet/parser/functions/function3x.rb\""
      PuppetLitmus::Serverspec.run_shell(cmd)
      output = JSON.parse(file(tmpfile).content)
      expect(output).to eq(expected)
    end
  end
end
