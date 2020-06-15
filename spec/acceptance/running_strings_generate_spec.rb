require 'spec_helper_acceptance'
include PuppetLitmus # rubocop:disable Style/MixinUsage This is fine

describe 'Generating module documentation using generate action' do
  before :all do
    # TODO: Linux only
    @sut_work_dir = PuppetLitmus::PuppetHelpers.run_shell("pwd").stdout.chomp

    test_module_path = sut_module_path(/Module test/)
    PuppetLitmus::PuppetHelpers.run_shell("puppet strings generate \"#{test_module_path}/**/*.{rb,pp}\"")
  end

  def expect_file_contain(path, expected_contents)
    file_path = File.join(@sut_work_dir, path)
    file_content = file(file_path).content
    expected_contents.each do |expected|
      expect(file_content).to include(expected)
    end
  end

  it 'should generate documentation for manifests' do
    expect_file_contain('doc/puppet_classes/test.html', ['Class: test'])
  end

  it 'should generate documentation for puppet functions' do
    skip('This test is failing. Appear to be legitimate failures.')
    expect_file_contain('doc/puppet_functions_puppet/test_3A_3Aadd.html', [
      'Adds two integers together.',
      # These tests are failing. Appear to be legitimate failures.
      '<p>The first integer to add.</p>',
      '<p>The second integer to add.</p>',
      '<p>Returns the sum of x and y.</p>'
    ])
  end

  it 'should generate documentation for 3x functions' do
    expect_file_contain('doc/puppet_functions_ruby3x/function3x.html', ['This is the function documentation for <code>function3x</code>'])
  end

  it 'should generate documentation for 4x functions' do
    expect_file_contain('doc/puppet_functions_ruby4x/function4x.html', ['This is a function which is used to test puppet strings'])
  end

  it 'should generate documentation for custom types' do
    expect_file_contain('doc/puppet_types/database.html', [
      '<p>An example server resource type.</p>',
      '<p>The database file to use.</p>',
      '<p>Documentation for a dynamic property.</p>',
      '<p>The database server name.</p>',
      '<p>Documentation for a dynamic parameter.</p>',
      '<p>The provider supports encryption.</p>',
    ])
  end

  it 'should generate documentation for custom providers' do
    expect_file_contain('doc/puppet_providers_database/linux.html', [
      'The database provider on Linux',
      '<tt>osfamily &mdash; linux</tt>',
      '<tt>database &mdash; /usr/bin/database</tt>',
    ])
  end

  it 'should generate documentation for puppet data types' do
    expect_file_contain('doc/puppet_data_types/AcceptanceDataType.html', [
      'A variant parameter called param1',
      'Optional String parameter called param2',
      '<h3>func1</h3>',
      '<p>func1 documentation</p>',
      '<p>param1 func1 documentation</p>',
      '<p>param2 func1 documentation</p>',
    ])
  end

  it 'should generate documentation for puppet data type aliases' do
    expect_file_contain('doc/puppet_data_type_aliases/Test_3A_3AElephant.html', [
      'Data Type: Test::Elephant',
      'types/elephant.pp',
      'A simple elephant type.',
    ])
  end

  it 'should generate documentation for enum tag' do
    expect_file_contain('doc/puppet_classes/test.html', [
      '<p class="tag_title">Enum Options (<tt>myenum</tt>):</p>',
      '<span class="name">a</span>',
      "&mdash; <div class='inline'>\n<p>Option A</p>\n</div>",
      '<span class="name">b</span>',
      "&mdash; <div class='inline'>\n<p>Option B</p>\n</div>",
    ])
  end
end
