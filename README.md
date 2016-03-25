**PLEASE NOTE that the puppetlabs-strings module is being deprecated in favor of a gem. 0.4.0 will be the last release of
the puppet module and the first release of the Ruby gem. Please see the installation instructions below.**

Puppet Strings
=============
[![Build Status](https://travis-ci.org/puppetlabs/puppetlabs-strings.png?branch=master)](https://travis-ci.org/puppetlabs/puppetlabs-strings)

A Puppet Face and plugin built on the
[YARD Documentation Tool](http://yardoc.org/) and the Puppet 4 Parser.
It is uses YARD and the Puppet Parser to generate HTML documentation about
Puppet code and Puppet extensions written in Ruby. It will eventually replace
the `puppet doc` command once feature parity has been achieved.


|                |                                                             |
| -------------- |------------------------------------------------------------ |
| *Code*         | [GitHub][repo]                                              |
| *Issues*       | [Puppet Labs' JIRA Tracker][JIRA]                           |
| *License*      | [Apache 2.0][LICENSE]                                       |
| *Change log*   | [CHANGELOG.md][changelog]                                   |
| *Contributing* | [CONTRIBUTING.md][changelog] and [COMMITTERS.md][committers]|

[repo]: https://github.com/puppetlabs/puppetlabs-strings
[JIRA]: https://tickets.puppetlabs.com/browse/PDOC
[LICENSE]: https://github.com/puppetlabs/puppetlabs-strings/blob/master/LICENSE
[changelog]: https://github.com/puppetlabs/puppetlabs-strings/blob/master/CHANGELOG.md
[contributing]: https://github.com/puppetlabs/puppetlabs-strings/blob/master/CONTRIBUTING.md
[committers]: https://github.com/puppetlabs/puppetlabs-strings/blob/master/COMMITTERS.md

Installation
------------
In order to run strings you need to have the following software installed:

  * Ruby 1.9.3 or newer
  * Puppet 3.7 or newer
  * The yard rubygem

Installing the Yard Gem
-----------------------

**Installing the Yard Gem with Puppet**


The easiest way to install the Yard gem is with Puppet itself.

For Puppet 4.x:
```
$ puppet resource package yard provider=puppet_gem
```

For Puppet 3.x:
```
$ puppet resource package yard provider=gem
```

Installing Strings Itself
-------------------------
Strings can be installed using the [puppet-strings Ruby gem](https://rubygems.org/gems/puppet-strings). To ensure it
is installed in right place, it is best to install it using Puppet.

For Puppet 4.x:
```
$ puppet resource package puppet-strings provider=puppet_gem
```

For Puppet 3.x:
```
$ puppet resource package puppet-strings provider=gem
```

Versions of less than or equal to 0.4.0 may be installed as a puppet module, but **this method of distribution is
deprecated and the module hosted on the Puppet Forge will no longer be updated after the 0.4.0 release.** The methods
for installing the module are:

Strings can be installed from the [Puppet Forge][forge strings] or from source.

[forge strings]: https://forge.puppetlabs.com/puppetlabs/strings

**Installing from the Forge**

Simply run this command and you're off to the races:

```
$ puppet module install puppetlabs-strings
```

**Installing from source**

Simply `git clone` this repository into your `modulepath`
(i.e. `/etc/puppet/modules`).


Running Puppet Strings
----------------------

Once strings has been installed you can document a puppet module:

```
$ cd /path/to/module
$ puppet strings
```

This processes `README` and all puppet and ruby files under `manifests/`
and `lib/`.

To document specific files:

```
$ puppet strings some_manifest.pp [another_if_you_feel_like_it.rb]
```

Strings can also emit the generated documentation as JSON:

```
$ puppet strings some_manifest.pp --emit-json documentation.json
```

It can also print the JSON to stdout:

```
$ puppet strings some_manifest.pp --emit-json-stdout
```

The schema for the JSON which Strings emits is [well documented](https://github.com/puppetlabs/puppetlabs-strings/blob/master/json_dom.md).

Processing is delegated to the `yardoc` tool so some options listed in `yard
help doc` are available.  However, Puppet Faces do not support passing
arbitrary options through a face so these options must be specified in a
`.yardopts` file.

In addition to generating a directory full of HTML, you can also serve up
documentation for all your modules using the `server` action:

```
$ puppet strings server
```

Writing Compatible Documentation
--------------------------------

Since the strings module is built around YARD, a few different comment formats
can be used.  YARD can work with RDoc, meaning it is backwards compatible with
previously documented modules.  Feel free to try out strings with RDoc, but we
are planning to move to Markdown as the standard.  You can configure which you
would like YARD to use by adding a `.yardopts` file to the root of your module
directory which specifies the desired format:

```
--markup markdown
```

While we have yet to decide exactly how documentation should work in the
future, here are some very basic examples to get you started using the strings
module. These are very much subject to change as we continue to work out a
style guide.

### Functions
Here's an example of how you might document a 4x function:

```ruby
# When given two numbers, returns the one that is larger.
# You could have a several line description here if you wanted,
# but I don't have much to say about this function.
#
# @example using two integers
#   $bigger_int = max(int_one, int_two)
#
# @return [Integer] the larger of the two parameters
#
# @param num_a [Integer] the first number to be compared
# @param num_b [Integer] the second number to be compared
Puppet::Functions.create_function(:max) do
  def max(num_a, num_b)
    num_a >= num_b ? num_a : num_b
  end
end
```

### Classes / Defined Types

Here's an example of how you might document a class:

```puppet
# This class is meant to serve as an example of how one might
# want to document a manifest in a way that is compatible.
# with the strings module
#
# @example when declaring the example class
#   include example
#
# @param first_arg The first parameter for this class
# @param second_arg The second paramter for this class
class example (
  $first_arg  = $example::params::first_arg,
  $second_arg = $exampe::params::second_arg,
) { }
```

### Types and Providers
Strings will automatically extract the `@doc` provider docstring and any `desc`
parameter/property docstrings.

Sometimes however, Puppet types use metaprogramming to create parameters
and methods automatically. In those cases Strings will not be able to document
them automatically (Strings doesn't execute the code that would generate those
parameters), so you will need to provide hints on how to document your code. To
document a parameter which is automatically created you must use the special
directive `@!puppet.type.param` which may take types, the parameter name,
and a description.

```ruby
# @!puppet.type.param my_parameter This parameter needs to be explicitly
# documented as it is generated by mk_resource_methods
Puppet::Type.newtype(:minifile) do

  @doc = "Manages files, including their content, ownership, and permissions.
    The provider can manage symbolic links."

  # This function does some metaprogramming on the new type.
  mk_resource_methods

  newparam(:path) do
    desc <<-'EOT'
      The path to the file to manage.  Must be fully qualified.
    EOT
    # ... do stuff here
  end
  # ...
end


```

Here are a few other good resources for getting started with documentation:

  * [Module README Template](https://docs.puppetlabs.com/puppet/latest/reference/modules_documentation.html)
  * [YARD Getting Started Guide](http://www.rubydoc.info/gems/yard/file/docs/GettingStarted.md)
  * [YARD Tags Overview](http://www.rubydoc.info/gems/yard/file/docs/Tags.md)

Rake Tasks
-----

This module is also available as a Gem and makes two rake tasks (`strings:generate` and `strings:serve`) available in `puppet-strings/rake_tasks`. To add this to your module's CI workflow, be sure to add this module to your `Gemfile`:

In addition to generating the usual 'doc' directory of HTML documentation, the `strings:generate` rake task will also
drop a strings.json file containing a JSON representation of the module into the directory the rake task was run from.

```ruby
gem 'puppet-strings', :git => 'https://github.com/puppetlabs/puppetlabs-strings.git'
```

To use the rake tasks, `require puppet-strings/rake_tasks` in your `Rakefile`:

```ruby
require 'puppet-strings/rake_tasks'
```

Developing and Contributing
-----

We love contributions from the community! If you'd like to contribute to the strings module,
check out [CONTRIBUTING.md](https://github.com/puppetlabs/puppetlabs-strings/blob/master/CONTRIBUTING.md) to get information on the contribution process.

Running Specs
-----

If you're going to be doing any development with puppet strings, it's essential
that you can run the spec tests. You should simply have to do the following:

    $ bundle install --path .bundle/gems
    $ bundle exec rake spec

Support
-----
Please log tickets and issues at our [JIRA tracker][JIRA].
A [mailing list](https://groups.google.com/forum/?fromgroups#!forum/puppet-users) is
available for asking questions and getting help from others. In addition there
is an active #puppet channel on Freenode.

We use semantic version numbers for our releases, and recommend that users stay
as up-to-date as possible by upgrading to patch releases and minor releases as
they become available.

Bugfixes and ongoing development will occur in minor releases for the current
major version. Security fixes will be backported to a previous major version on
a best-effort basis, until the previous major version is no longer maintained.

Caveats
-------

  - Documentation blocks must immediately precede the documented code with no
    whitespace.  This is because the comment extractor possesses the elegance
    and intelligence of a bag of hammers.

  - This project is very much a work in progress and may very well have
    undiscovered bugs and pitfalls. If you discover any of these,
    [please file a ticket](https://tickets.puppetlabs.com/browse/PDOC).
