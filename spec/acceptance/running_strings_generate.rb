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

  it 'should generate documentation for puppet functions' do
    puppet_version = on(master, facter('puppetversion')).stdout.chomp.to_i

    if puppet_version >= 4
      html_output = read_file_on(master, '/root/doc/puppet_functions_puppet/test_3A_3Aadd.html')
      expect(html_output).to include('Adds two integers together.')
      expect(html_output).to include('<pre class="example code"><code>test::add(1, 2) =&gt; 3</code></pre>')
      expect(html_output).to include('<p>The first integer to add.</p>')
      expect(html_output).to include('<p>The second integer to add.</p>')
      expect(html_output).to include('<p>Returns the sum of x and y.</p>')
    end
  end

  it 'should generate documentation for 3x functions' do
    expect(read_file_on(master, '/root/doc/puppet_functions_ruby3x/function3x.html')).to include('This is the function documentation for <code>function3x</code>')
  end

  it 'should generate documentation for 4x functions' do
    expect(read_file_on(master, '/root/doc/puppet_functions_ruby4x/function4x.html')).to include('This is a function which is used to test puppet strings')
  end

  it 'should generate documentation for custom types' do
    html_output = read_file_on(master, '/root/doc/puppet_types/database.html')
    expect(html_output).to include('<p>An example server resource type.</p>')
    expect(html_output).to include('<p>The database file to use.</p>')
    expect(html_output).to include('<p>Documentation for a dynamic property.</p>')
    expect(html_output).to include('<p>The database server name.</p>')
    expect(html_output).to include('<p>Documentation for a dynamic parameter.</p>')
    expect(html_output).to include('<p>The provider supports encryption.</p>')
  end

  it 'should generate documentation for custom providers' do
    html_output = read_file_on(master, '/root/doc/puppet_providers_database/linux.html')
    expect(html_output).to include('The database provider on Linux')
    expect(html_output).to include('<tt>osfamily &mdash; linux</tt>')
    expect(html_output).to include('<tt>database &mdash; /usr/bin/database</tt>')
  end
end
