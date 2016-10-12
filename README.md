Puppet Strings
==============
[![Build Status](https://travis-ci.org/puppetlabs/puppet-strings.png?branch=master)](https://travis-ci.org/puppetlabs/puppet-strings) [![Gem Version](https://badge.fury.io/rb/puppet-strings.svg)](https://badge.fury.io/rb/puppet-strings)

A Puppet command built on [YARD](http://yardoc.org/).

Puppet Strings generates HTML documentation for Puppet extensions written in Puppet and Ruby.

This tool will eventually place the existing `puppet doc` command once feature parity has been achieved.

|                |                                                                 |
| -------------- |---------------------------------------------------------------- |
| *Code*         | [GitHub][repo]                                                  |
| *Issues*       | [Puppet JIRA Tracker][JIRA]                                     |
| *License*      | [Apache 2.0][LICENSE]                                           |
| *Change log*   | [CHANGELOG.md][changelog]                                       |
| *Contributing* | [CONTRIBUTING.md][contributing] and [COMMITTERS.md][committers] |

[repo]: https://github.com/puppetlabs/puppet-strings
[JIRA]: https://tickets.puppetlabs.com/browse/PDOC
[LICENSE]: https://github.com/puppetlabs/puppet-strings/blob/master/LICENSE
[changelog]: https://github.com/puppetlabs/puppet-strings/blob/master/CHANGELOG.md
[contributing]: https://github.com/puppetlabs/puppet-strings/blob/master/CONTRIBUTING.md
[committers]: https://github.com/puppetlabs/puppet-strings/blob/master/COMMITTERS.md

Requirements
------------

In order to run strings you need to have the following software installed:

  * Ruby 1.9.3 or newer
  * Puppet 3.7 or newer
  * The `yard` Ruby gem

Note that a few extra steps are necessary to install puppet-strings with Puppet Enterprise 3.8.

Installing the YARD Gem
-----------------------

The easiest way to install the `yard` gem is with Puppet itself:

For Puppet 4.x:
```
$ puppet resource package yard provider=puppet_gem
```

For Puppet 3.x:
```
$ puppet resource package yard provider=gem
```

For Puppet Enterprise 3.8:
```
GEM_HOME=/opt/puppet/lib/ruby/gems/1.9.1 puppet resource package yard provider=gem
```

Installing the redcarpet Gem (Puppet Enterprise 3.8 only)
-------------------------
```
GEM_HOME=/opt/puppet/lib/ruby/gems/1.9.1 puppet resource package redcarpet provider=gem
```

Installing Puppet Strings
-------------------------

Strings can be installed using the [puppet-strings](https://rubygems.org/gems/puppet-strings) gem.

To ensure it is installed in right place, it is best to install it using Puppet:

For Puppet 4.x:
```
$ puppet resource package puppet-strings provider=puppet_gem
```

For Puppet 3.x:
```
$ puppet resource package puppet-strings provider=gem
```

For Puppet Enterprise 3.8:
```
GEM_HOME=/opt/puppet/lib/ruby/gems/1.9.1 puppet resource package puppet-strings provider=gem
```

Running Puppet Strings
----------------------

Once strings has been installed you can document a puppet module:

```
$ cd /path/to/module
$ puppet strings
```

This processes `README` and all Puppet and Ruby source files under the `./manifests/`, `./functions/`, and `./lib/`
directories by default and creates HTML documentation under the `./doc/` directory.

To document specific files:

```
$ puppet strings generate first.pp second.pp ...
```

To document specific directories:

```
$ puppet strings generate 'modules/foo/lib/**/*.rb' 'modules/foo/manifests/**/*.pp' 'modules/foo/functions/**/*.pp' ...
```

Strings can emit JSON documenting the Puppet extensions:

```
$ puppet strings generate --emit-json documentation.json
```

It can also print the JSON to stdout:

```
$ puppet strings generate --emit-json-stdout
```

The schema for the JSON output is [documented here](https://github.com/puppetlabs/puppet-strings/blob/master/JSON.md).

In addition to generating a directory full of HTML, you can also serve up documentation for all your modules using the `server` action:

```
$ puppet strings server
```

YARD Options
------------

YARD options (see `yard help doc`) are supported in a `.yardopts` file in the same directory where `puppet strings` is run.

Puppet Strings automatically sets the `markup` option to `markdown`, allowing your documentation strings to be in Markdown format.

Documenting Puppet Extensions
-----------------------------

### Puppet Classes / Defined Types

To document Puppet classes and defined types, use a YARD docstring before the class or defined type definition:

```puppet
# An example class.
#
# This is an example of how to document a Puppet class
#
# @example Declaring the class
#   include example
#
# @param first The first parameter for this class
# @param second The second paramter for this class
class example_class(
  String $first  = $example::params::first_arg,
  Integer $second = $example::params::second_arg,
) inherits example::params {
  # ...
}

# An example defined type.
#
# This is an example of how to document a defined type.
# @param ports The array of port numbers to use.
define example_type(
   Array[Integer] $ports = []
) {
  # ...
}
```

***Note: unlike Ruby, Puppet 4.x is a typed language; Puppet Strings will automatically use the parameter type information to
document the parameter types.  A warning will be emitted if you document a parameter's type for a parameter that has a Puppet type specifier.***

### Resource Types

To document custom resource types and their parameters/properties, use the `desc` method or assign a value to the `doc` attribute:

```ruby
Puppet::Type.newtype(:example) do
  desc <<-DESC
An example resource type.
@example Using the type.
  example { foo:
    param => 'hi'
  }
DESC

  newparam(:param) do
    desc 'An example parameter.'
    # ...
  end

  newproperty(:prop) do
    desc 'An example property.'
    #...
  end

  # ...  
end
```

Puppet Strings documents this way to preserve backwards compatibility with `puppet doc` and existing resource types.

***Note: Puppet Strings does not evaluate your Ruby code, so only certain static expressions are supported.***

To document parameters and properties that are dynamically created, use the `#@!puppet.type.param` and `#@!puppet.type.property`
directives before the `newtype` call:

```ruby
# @!puppet.type.param [value1, value2, value3] my_param Documentation for a dynamic parameter.
# @!puppet.type.property [foo, bar, baz] my_prop Documentation for a dynamic property.
Puppet::Type.newtype(:example) do
  #...
end
```

### Providers

To document providers, use the `desc` method or assign a value to the `doc` attribute:

```ruby
Puppet::Type.type(:example).provide :platform do
  desc 'An example provider.'

  # ...
end
```

Puppet Strings documents this way to preserve backwards compatibility with `puppet doc` and existing resource types.

***Note: Puppet Strings does not evaluate your Ruby code, so only certain static expressions are supported.***

### Functions

Puppet Strings supports three different ways of defining a function in Puppet: with the Puppet 3.x API, Puppet 4.X API,
and in the Puppet language itself.

#### Puppet 3.x Functions

To document a function in the Puppet 3.x API, use the `doc` option to `newfunction`:

```ruby
Puppet::Parser::Functions.newfunction(:example, doc: <<-DOC
Documentation for an example 3.x function.
@param [String] param1 The first parameter.
@param [Integer] param2 The second parameter.
@return [Undef]
@example Calling the function.
  example('hi', 10)
DOC
) do |*args|
  #...
end
```

***Note: if parameter types are omitted, a default of the `Any` Puppet type will be used.***

#### Puppet 4.x Functions

To document a function in the Puppet 4.x API, use a YARD docstring before the `create_function` call and any `dispatch`
calls:

```ruby
# An example 4.x function.
Puppet::Functions.create_function(:example) do
  # @param first The first parameter.
  # @param second The second parameter.
  # @return [String] Returns a string.
  # @example Calling the function
  #   example('hi', 10)
  dispatch :example do
    param 'String', :first
    param 'Integer', :second
  end

  # ...
end
```

***Note: Puppet Strings will automatically use the parameter type information from the `dispatch` block to document
the parameter types. Only document your parameter types when the Puppet 4.x function contains no `dispatch` calls.***

If the Puppet 4.x function contains multiple `dispatch` calls, Puppet Strings will automatically create `overload` tags
to describe the function's overloads:

```ruby
# An example 4.x function.
Puppet::Functions.create_function(:example) do
  # Overload by string.
  # @param first The first parameter.
  # @return [String] Returns a string.
  # @example Calling the function
  #   example('hi')
  dispatch :example_string do
    param 'String', :first
  end

  # Overload by integer.
  # @param first The first parameter.
  # @return [Integer] Returns an integer.
  # @example Calling the function
  #   example(10)
  dispatch :example_integer do
    param 'Integer', :first
  end

  # ...
```

The resulting HTML for this example function will document both `example(String $first)` and `example(Integer $first)`.

#### Puppet Language Functions

To document Puppet functions written in the Puppet language, use a YARD docstring before the function definition:

```puppet
# An example function written in Pupppet.
# @param name The name to say hello to.
# @return [String] Returns a string.
# @example Calling the function
#   example('world')
function example(String $name) {
  "hello $name"
}
```

***Note: Puppet Strings will automatically use the parameter type information from the function's parameter list to document
the parameter types.***

Further examples
----------------

#### Using The `@example` Tag

The `@example` YARD tag can be used to add usage examples to any Ruby or Puppet language code.

```puppet
# @example String describing what this example demonstrates.
#   $content = example('world')
#   if $content == 'world' {
#     include world
#   }
function example(string $name) {
  "hello $name"
}
```

The string following the `@example` tag is an optional title which is displayed prominently above the code block.

The example body must begin on a newline underneath the tag, and each line of the example itself must be indented by
at least one space. Further indentation is preserved as preformatted text in the generated documentation.

Additional Resources
--------------------

Here are a few other good resources for getting started with documentation:

  * [Module README Template](https://docs.puppet.com/puppet/latest/reference/modules_documentation.html)
  * [YARD Getting Started Guide](http://www.rubydoc.info/gems/yard/file/docs/GettingStarted.md)
  * [YARD Tags Overview](http://www.rubydoc.info/gems/yard/file/docs/Tags.md)

Rake Tasks
----------

Puppet Strings comes with two rake tasks: `strings:generate` and `strings:gh_pages:update` available in `puppet-strings/tasks`.

Add the following to your Gemfile to use `puppet-strings`:

```ruby
gem 'puppet-strings', :git => 'https://github.com/puppetlabs/puppet-strings.git'
```

In your `Rakefile`, add the following to use the `puppet-strings` tasks:

```ruby
require 'puppet-strings/tasks'
```

The `strings:generate` task can be used to generate documentation:

```
$ rake strings:generate
```

The task accepts the following parameters:

* `patterns`: the search patterns to use for finding files to document (defaults to `manifests/**/*.pp functions/**/*.pp types/**/*.pp lib/**/*.rb`).
* `debug`: enables debug output when set to `true`.
* `backtrace`: enables backtraces for errors when set to `true`.
* `markup`: the markup language to use (defaults to `markdown`).
* `yard_args`: additional arguments to pass to YARD.

An example of passing arguments to the `strings:generate` Rake task:

```
$ rake strings:generate\['**/*{.pp\,.rb}, true, true, markdown, --readme README.md']
```

The `strings:gh_pages:update` task will generate your Puppet Strings documentation to be made available via [GitHub Pages](https://pages.github.com/). It will:

1. Create a `doc` directory in the root of your project
2. Check out the `gh-pages` branch of the current repository in the `doc` directory (it will create a branch if one does not already exist)
3. Generate strings documentation using the `strings:generate` task
4. Commit the changes and push them to the `gh-pages` branch **with the `--force` flag**

This task aims to keep the `gh-pages` branch up to date with the current code and uses the `-f` flag when pushing to the `gh-pages` branch.
***Please note this operation will be destructive if not used properly.***

Developing and Contributing
---------------------------

We love contributions from the community!

If you'd like to contribute to the strings module, check out [CONTRIBUTING.md](https://github.com/puppetlabs/puppet-strings/blob/master/CONTRIBUTING.md) to get information on the contribution process.

Running Specs
-------------

If you plan on developing features or fixing bugs in Puppet Strings, it is essential that you run specs before opening a pull request.

To run specs, simply execute the `spec` rake task:

    $ bundle install --path .bundle/gems
    $ bundle exec rake spec

Support
-------

Please log tickets and issues at our [JIRA tracker][JIRA]. A [mailing list](https://groups.google.com/forum/?fromgroups#!forum/puppet-users)
is available for asking questions and getting help from others.

There is also an active #puppet channel on the Freenode IRC network.

We use semantic version numbers for our releases, and recommend that users stay as up-to-date as possible by upgrading to
patch releases and minor releases as they become available.

Bug fixes and ongoing development will occur in minor releases for the current major version.
Security fixes will be ported to a previous major version on a best-effort basis, until the previous major version is no longer maintained.
