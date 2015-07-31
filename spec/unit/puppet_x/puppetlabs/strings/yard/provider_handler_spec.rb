require 'spec_helper'
require 'puppet_x/puppetlabs/strings/yard/handlers/provider_handler'
require 'strings_spec/parsing'


describe PuppetX::PuppetLabs::Strings::YARD::Handlers::PuppetProviderHandler do
  include StringsSpec::Parsing

  def the_provider()
    YARD::Registry.at("file")
  end

  it "should have the proper docstring" do
    parse  <<-RUBY
      Puppet::Type.newtype(:file) do
        @doc = "Manages files, including their content, ownership, and perms."
        newparam(:path) do
          desc <<-'EOT'
            The path to the file to manage.  Must be fully qualified.
          EOT
        end
        isnamevar
      end
    RUBY

    expect(the_provider.docstring).to eq("Manages files, including their " +
      "content, ownership, and perms.")
  end

  it "should have the proper parameter details" do
    parse  <<-RUBY
      Puppet::Type.newtype(:file) do
        @doc = "Manages files, including their content, ownership, and perms."
        newparam(:path) do
          desc <<-'EOT'
            The path to the file to manage.  Must be fully qualified.
          EOT
        end
        isnamevar
      end
    RUBY

    expect(the_provider.parameter_details).to eq([{ :name => "path",
      :desc => "The path to the file to manage.  Must be fully qualified.",
      :exists? => true, :provider => true, }])
  end

  it "should have the proper parameters" do
    parse  <<-RUBY
      Puppet::Type.newtype(:file) do
        @doc = "Manages files, including their content, ownership, and perms."
        newparam(:path) do
          desc <<-'EOT'
            The path to the file to manage.  Must be fully qualified.
          EOT
        end
        isnamevar
      end
    RUBY

    expect(the_provider.parameters).to eq([["path", nil]])
  end
end
