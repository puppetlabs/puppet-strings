Puppet Strings
=============
[![Build Status](https://travis-ci.org/puppetlabs/puppetlabs-strings.png?branch=master)](https://travis-ci.org/puppetlabs/puppetlabs-strings)

A Puppet Face and plugin built on the [YARD Documentation Tool](http://yardoc.org/) and Puppet Future Parser.
It is uses YARD and the Puppet Parser to generate HTML documentation about
Puppet code and Puppet extensions written in Ruby. It will eventually replace
the `puppet doc` command once feature parity has been achieved.

Installation
------------
In order to run strings you need to have the following software installed:

  * Ruby 1.9.3 or newer
  * Puppet 3.7 or newer
  * The yard rubygem

In order to install the strings module, simply `git clone` this repository into
your `modulepath` (i.e. `/etc/puppet/modules`). This module is also available
on the [Puppet Forge](https://forge.puppetlabs.com/puppetlabs/strings) and can be installed with `puppet module install puppetlabs-strings`.

Running Puppet Strings
-----
If you cloned the repository into your `modulepath` and installed the needed
gems, you can do the following to document a module:

    $ cd /path/to/module
    $ puppet strings

This processes `README` and everything in `manifests/**/*.pp`.

To document specific manifests:

    $ puppet strings some_manifest.pp [another_if_you_feel_like_it.pp]

Processing is delegated to the `yardoc` tool so some options listed in `yard help doc` are available.
However, Puppet Faces do not support passing arbitrary options through a face so these options must be specified in a `.yardopts` file.

In addition to generating a directory full of HTML, you can also serve up
documentation for all your modules using the `server` action:

    $ puppet strings server

Writing Compatible Documentation
-----
Since the strings module is built around YARD, a few different comment formats can be used.
YARD can work with RDoc, meaning it is backwards compatible with previously documented modules.
Feel free to try out strings with RDoc, but we are planning to move to Markdown as the standard.
You can configure which you would like YARD to use by adding a `.yardopts` file to the root of
your module directory which specifies the desired format:

    --markup markdown

While we have yet to decide exactly how documentation should work in the future, here are some
very basic examples to get you started using the strings module. These are very much subject
to change as we continue to work out a style guide.

Here's an example of how you might document a 4x function:

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

And here's an example of how you might document a class:

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
       $first_arg = $example::params::first_arg,
       $second_arg = $exampe::params::second_arg,
     ) { }

Here are a few other good resources for getting started with documentation:

  * [Module README Template](https://docs.puppetlabs.com/puppet/latest/reference/modules_documentation.html)
  * [YARD Getting Started Guide](http://www.rubydoc.info/gems/yard/file/docs/GettingStarted.md)
  * [YARD Tags Overview](http://www.rubydoc.info/gems/yard/file/docs/Tags.md)

Rake Tasks
-----

This module is also available as a Gem and makes two rake tasks (`generate` and `serve`) available in `puppet-strings/rake_tasks`. To add this to your module's CI workflow, be sure to add this module to your `Gemfile`:

    gem 'puppet-strings', :git => 'https://github.com/puppetlabs/puppet-strings.git'

To use the rake tasks, `require puppet-strings/rake_tasks` in your `Rakefile`:

    require 'puppet-strings/rake_tasks'

License
-----
See [LICENSE](https://github.com/puppetlabs/puppetlabs-strings/blob/master/LICENSE) file.

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
Please log tickets and issues at our [JIRA tracker](http://tickets.puppetlabs.com). The
puppet strings project can be found under [PDOC](https://tickets.puppetlabs.com/browse/PDOC) on JIRA.
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

  - At the moment, only top-level Classes and Defined Types are parsed and formatted.

  - Documentation blocks must immediately precede the documented code with no whitespace.
    This is because the comment extractor possesses the elegance and intelligence of a bag of hammers.

  - This project is very much a work in progress and may very well have undiscovered bugs and pitfalls.
    If you discover any of these, [please file a ticket](https://tickets.puppetlabs.com/browse/PDOC).
