require 'spec_helper'
require 'puppet_x/puppet/strings/yard/handlers/type_handler'
require 'strings_spec/parsing'


describe PuppetX::Puppet::Strings::YARD::Handlers::PuppetTypeHandler do
  include StringsSpec::Parsing

  def the_type()
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

    expect(the_type.docstring).to eq("Manages files, including their " +
      "content, ownership, and perms.")
  end

  it "should have the proper parameter details" do
    parse  <<-RUBY
      Puppet::Type.newtype(:file) do
        @doc = "Manages files, including their content, ownership, and perms."
        newparam(:file) do
          desc <<-'EOT'
            The path to the file to manage.  Must be fully qualified.
          EOT
        end
        isnamevar
      end
    RUBY

    expect(the_type.parameter_details).to eq([{ :name => "file",
      :desc => "The path to the file to manage.  Must be fully qualified.",
      :exists? => true, :puppet_type => true, :namevar => true,
      :default => nil,
      :parameter=>true,
      :allowed_values=>[],
    }])
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

    expect(the_type.parameters).to eq([["path", nil]])
  end
end
