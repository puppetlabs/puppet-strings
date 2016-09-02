Puppet Strings
=============
[![Build Status](https://travis-ci.org/puppetlabs/puppetlabs-strings.png?branch=master)](https://travis-ci.org/puppetlabs/puppetlabs-strings) [![Gem Version](https://badge.fury.io/rb/puppet-strings.svg)](https://badge.fury.io/rb/puppet-strings)

A Puppet Face and plugin built on the [YARD Documentation Tool](http://yardoc.org/) and the Puppet 4 Parser. It is uses YARD and the Puppet Parser to generate HTML documentation about Puppet code and Puppet extensions written in Ruby. It will eventually replace the `puppet doc` command once feature parity has been achieved.


|                |                                                             |
| -------------- |------------------------------------------------------------ |
| *Code*         | [GitHub][repo]                                              |
| *Issues*       | [Puppet Labs' JIRA Tracker][JIRA]                           |
| *License*      | [Apache 2.0][LICENSE]                                       |
| *Change log*   | [CHANGELOG.md][changelog]                                   |
| *Contributing* | [CONTRIBUTING.md][contributing] and [COMMITTERS.md][committers]|

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
  * The YARD RubyGem

Installing the YARD Gem
-----------------------
**Installing the YARD Gem with Puppet**

The easiest way to install the YARD gem is with Puppet itself.

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
**PLEASE NOTE** that Strings was previously distributed via the puppetlabs-strings module. This is no longer the preferred method of installation as the module will not longer receive updates. So even though there is still a module on the Puppet Forge, please use the RubyGem.

Strings can be installed using the [puppet-strings RubyGem](https://rubygems.org/gems/puppet-strings). To ensure it is installed in right place, it is best to install it using Puppet.

For Puppet 4.x:
```
$ puppet resource package puppet-strings provider=puppet_gem
```

For Puppet 3.x:
```
$ puppet resource package puppet-strings provider=gem
```

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
$ puppet strings yardoc some_manifest.pp --emit-json documentation.json
```

It can also print the JSON to stdout:

```
$ puppet strings yardoc some_manifest.pp --emit-json-stdout
```

The schema for the JSON which Strings emits is [well documented](https://github.com/puppetlabs/puppetlabs-strings/blob/master/json_dom.md).

Processing is delegated to the `yardoc` tool so some options listed in `yard help doc` are available.  However, Puppet Faces do not support passing arbitrary options through a face so these options must be specified in a `.yardopts` file.

In addition to generating a directory full of HTML, you can also serve up documentation for all your modules using the `server` action:

```
$ puppet strings server
```

Writing Compatible Documentation
--------------------------------

Since the strings module is built around YARD, a few different comment formats can be used.  YARD can work with RDoc, meaning it is backwards compatible with previously documented modules.  Feel free to try out strings with RDoc, but we are planning to move to Markdown as the standard.  You can configure which you would like YARD to use by adding a `.yardopts` file to the root of your module directory which specifies the desired format:

```
--markup markdown
```

While we have yet to decide exactly how documentation should work in the future, here are some very basic examples to get you started using the strings module. These are very much subject to change as we continue to work out a style guide.

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
Strings will automatically extract the `@doc` provider docstring and any `desc` parameter/property docstrings.

Sometimes however, Puppet types use metaprogramming to create parameters and methods automatically. In those cases Strings will not be able to document them automatically (Strings doesn't execute the code that would generate those parameters), so you will need to provide hints on how to document your code. To document a parameter which is automatically created you must use the special directive `@!puppet.type.param` which may take types, the parameter name, and a description.

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

This module is also available as a Gem and makes three rake tasks (`strings:generate`, `strings:serve`, and `strings:gh_pages:update`) available in `puppet-strings/rake_tasks`. To add this to your module's CI workflow, be sure to add this module to your `Gemfile`:

```ruby
gem 'puppet-strings', :git => 'https://github.com/puppetlabs/puppetlabs-strings.git'
```

In addition to generating the usual 'doc' directory of HTML documentation, the `strings:generate` rake task will also drop a strings.json file containing a JSON representation of the module into the directory the rake task was run from.

To use the rake tasks, `require puppet-strings/rake_tasks` in your `Rakefile`:

```ruby
require 'puppet-strings/rake_tasks'
```

The task `strings:generate` which is provided by including `puppet-strings/rake_tasks` will scan the manifests and lib directory from your single module. If you need to document a complete, or part of a, puppet tree, you can use the `PuppetStrings::RakeTasks::Generate` task. This rake task will by default overwrite strings:generate unless you specify a custom name. See the example below on how you can use it and which options it supports.

```ruby
require 'puppet-strings/rake_tasks/generate'

PuppetStrings::RakeTasks::Generate.new(:documentation) do |task|
  task.paths = ['site/roles','site/profiles','modules/internal']
  task.excludes = ['/vendor/','/example/']
  task.options = {} # disables the strings.json output
  # module_resourcefiles are the patterns of included files. Below is the default.
  # task.module_resourcefiles = ['manifests/**/*.pp', 'lib/**/*.rb']
end
```

The `strings:gh_pages:update` task will generate your Strings documentation to be made available via [GitHub Pages](https://pages.github.com/). It will:

  1. Create a `doc` directory in the root of your project
  2. Check out the `gh-pages` branch of the current repository in the `doc` directory (it will create a branch if one does not already exist)
  3. Generate strings documentation using the `strings:generate` task
  4. Commit the changes and push them to the `gh-pages` branch **with the `-f` flag**

This task aims to keep the `gh-pages` branch up to date with the current code and uses the `-f` flag when pushing to the `gh-pages` branch. Please keep this in mind as it **will be destructive** if not used properly.

Developing and Contributing
-----

We love contributions from the community! If you'd like to contribute to the strings module, check out [CONTRIBUTING.md](https://github.com/puppetlabs/puppetlabs-strings/blob/master/CONTRIBUTING.md) to get information on the contribution process.

Running Specs
-----

If you're going to be doing any development with puppet strings, it's essential that you can run the spec tests. You should simply have to do the following:

    $ bundle install --path .bundle/gems
    $ bundle exec rake spec

Support
-----
Please log tickets and issues at our [JIRA tracker][JIRA]. A [mailing list](https://groups.google.com/forum/?fromgroups#!forum/puppet-users) is available for asking questions and getting help from others. In addition there is an active #puppet channel on Freenode.

We use semantic version numbers for our releases, and recommend that users stay as up-to-date as possible by upgrading to patch releases and minor releases as they become available.

Bugfixes and ongoing development will occur in minor releases for the current major version. Security fixes will be backported to a previous major version on a best-effort basis, until the previous major version is no longer maintained.

Caveats
-------

  - Documentation blocks must immediately precede the documented code with no whitespace.  This is because the comment extractor possesses the elegance and intelligence of a bag of hammers.

  - This project is very much a work in progress and may very well have undiscovered bugs and pitfalls. If you discover any of these, [please file a ticket](https://tickets.puppetlabs.com/browse/PDOC).
