Puppet Strings
=============

A Puppet Face and plugin built on the [YARD Documentation Tool](http://yardoc.org/) and Puppet Future Parser.
It is uses YARD and the Puppet Parser to generate HTML documentation about
Puppet code and Puppet extensions written in Ruby. It will eventually replace
the `puppet doc` command once feature parity has been achieved.

Installation
------------

In most cases, the following will need to be installed:

* A supported Ruby version. Ruby 1.9.3 and 2.0.0 are fully supported. Anything older than Ruby 1.9 is not supported.
* A supported Puppet version. Anything older than Puppet 3.6.x is not supported.

In order to install the strings module, simply `git clone` this repository into
your `modulepath` (i.e. `/etc/puppet/modules`) and ensure that you have the
`yard` and `rgen` gems installed.

Alternatively, you can clone the repository elsewhere and run the `puppet strings`
command directly from the source directory if you install the need gems via
bundler and the provided Gemfile.

Once this module has been officially released to the Forge, you will also be
able to install it using the `puppet module install` command.

Running Puppet Strings
-----

If you cloned the repository into your `modulepath` and installed the needed
gems, you can do the following to document a module:

    $ cd /path/to/module
    $ puppet strings

This processes `README` and everything in `manifests/**/*.pp`.

Documenting specific manifests:

   $ puppet strings some_manifest.pp [another_if_you_feel_like_it.pp]

If you would like to run strings from the source directory as described above, you'll
want to install the needed gems and run via bundler:

    $ bundle install --path .bundle/gems
    $ bundle exec puppet strings

Processing is delegated to the `yardoc` tool so some options listed in `yard help doc` are available.
However, Puppet Faces do not support passing arbitrary options through a face so these options must be specified in a `.yardopts` file.

The strings face does offer two actions. In addition to generating a
directory full of HTML, you can also serve up documentation for all your
modules using the `server` action:

    $ puppet strings serever

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

Long-term support, including security patches and bug fixes, is available for
commercial customers. Please see the following page for more details:

[Puppet Enterprise Support Lifecycle](http://puppetlabs.com/misc/puppet-enterprise-lifecycle)

Caveats
-------

  - At the moment, only top-level Classes and Defined Types are parsed and formatted.

  - Documentation blocks must immediately precede the documented code with no whitespace.
    This is because the comment extractor possesses the elegance and intelligance of a bag of hammers.

  - This project is very much a work in progress and may very well have undiscovered bugs and pitfalls.
    If you discover any of these, [please file a ticket](https://tickets.puppetlabs.com/browse/PDOC).
