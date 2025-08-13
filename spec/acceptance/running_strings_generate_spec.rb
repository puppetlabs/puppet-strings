# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'Generating module documentation using generate action' do
  def expect_file_contain(path, expected_contents)
    test_module_path = File.absolute_path(File.join('spec', 'fixtures', 'acceptance', 'modules', 'test'))
    Dir.mktmpdir do |tmpdir|
      Dir.chdir(tmpdir) do
        _stdout, _stderr, status = Open3.capture3("puppet strings generate \"#{test_module_path}/**/*.{rb,pp}\"")
        expect(status.success?).to be true
        expected_contents.each do |expected|
          expect(File.read(path)).to include(expected)
        end
      end
    end
  end

  it 'generates documentation for manifests' do
    expect_file_contain('doc/puppet_classes/test.html', ['Class: test'])
  end

  it 'generates documentation for puppet functions' do
    skip('This test is failing. Appear to be legitimate failures.')
    expect_file_contain('doc/puppet_functions_puppet/test_3A_3Aadd.html', [
                          'Adds two integers together.',
                          # These tests are failing. Appear to be legitimate failures.
                          '<p>The first integer to add.</p>',
                          '<p>The second integer to add.</p>',
                          '<p>Returns the sum of x and y.</p>',
                        ])
  end

  it 'generates documentation for 3x functions' do
    expect_file_contain('doc/puppet_functions_ruby3x/function3x.html', ['This is the function documentation for <code>function3x</code>'])
  end

  it 'generates documentation for 4x functions' do
    expect_file_contain('doc/puppet_functions_ruby4x/function4x.html', ['This is a function which is used to test puppet strings'])
  end

  it 'generates documentation for custom types' do
    expect_file_contain('doc/puppet_types/database.html', [
                          '<p>An example server resource type.</p>',
                          '<p>The database file to use.</p>',
                          '<p>Documentation for a dynamic property.</p>',
                          '<p>The database server name.</p>',
                          '<p>Documentation for a dynamic parameter.</p>',
                          '<p>The provider supports encryption.</p>',
                        ])
  end

  it 'generates documentation for custom providers' do
    expect_file_contain('doc/puppet_providers_database/linux.html', [
                          'The database provider on Linux',
                          '<tt>osfamily &mdash; linux</tt>',
                          '<tt>database &mdash; /usr/bin/database</tt>',
                        ])
  end

  it 'generates documentation for puppet data types' do
    expect_file_contain('doc/puppet_data_types/AcceptanceDataType.html', [
                          'A variant parameter called param1',
                          'Optional String parameter called param2',
                          '<h3>func1</h3>',
                          '<p>func1 documentation</p>',
                          '<p>param1 func1 documentation</p>',
                          '<p>param2 func1 documentation</p>',
                        ])
  end

  it 'generates documentation for puppet data type aliases' do
    expect_file_contain('doc/puppet_data_type_aliases/Test_3A_3AElephant.html', [
                          'Data Type: Test::Elephant',
                          'types/elephant.pp',
                          'A simple elephant type.',
                        ])
  end

  it 'generates documentation for enum tag' do
    expect_file_contain('doc/puppet_classes/test.html', [
                          '<p class="tag_title">Enum Options (<tt>myenum</tt>):</p>',
                          '<span class="name">a</span>',
                          "&mdash; <div class='inline'><p>Option A</p>\n</div>",
                          '<span class="name">b</span>',
                          "&mdash; <div class='inline'><p>Option B</p>\n</div>",
                        ])
  end
end
