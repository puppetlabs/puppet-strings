Puppet Strings
==============
[![Build Status](https://travis-ci.org/puppetlabs/puppet-strings.png?branch=master)](https://travis-ci.org/puppetlabs/puppet-strings) [![Gem Version](https://badge.fury.io/rb/puppet-strings.svg)](https://badge.fury.io/rb/puppet-strings)

Puppet Strings generates documentation for Puppet code and extensions written in Puppet and Ruby. Strings processes code and YARD-style code comments to create documentation in HTML, Markdown, or JSON formats.


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

## Installing Puppet Strings

### Requirements

  * Ruby 2.1.9 or newer
  * Puppet 4.0 or newer
  * The `yard` Ruby gem

### Install Puppet Strings

1. Install the YARD gem by running `sudo /opt/puppetlabs/puppet/bin/gem install yard`
1. Install the `puppet-strings` gem by running `sudo /opt/puppetlabs/puppet/bin/gem install puppet-strings`
1. **Optional**: Set YARD options for Strings

   To use YARD options with Puppet Strings, specify a `yardopts` file in the same directory in which you run `puppet strings`. Puppet Strings supports the Markdown format and automatically sets the YARD `markup` option to `markdown`.

   To see a list of available YARD options, run `yard help doc`. For details about YARD options configuration, see the [YARD docs](http://www.rubydoc.info/gems/yard/file/docs/GettingStarted.md#config).


## Generating documentation with Puppet Strings

By default, Puppet Strings outputs documentation as HTML, or you can specify JSON or Markdown output instead.

Strings generates reference documentation based on the code and Strings code comments in all Puppet and Ruby source files under the `./manifests/`, `./functions/`, `./lib/`, `./types/`, and `./tasks/` directories.

Strings outputs HTML of the reference information and the module README to the module's `./doc/` directory. This output can be rendered in any browser.

JSON and Markdown output include the reference documentation only. Strings sends JSON output to either STDOUT or to a file. Markdown output is written to a REFERENCE.md file in the module's main directory.

See the [Puppet Strings documentation](https://puppet.com/docs/puppet/latest/puppet_strings.html) for complete instructions for generating documentation with Strings. For code comment style guidelines and examples, see the [Puppet Strings style guide](https://puppet.com/docs/puppet/5.5/puppet_strings_style.html).

### Additional Resources

Here are a few other good resources for getting started with documentation:

  * [Module README Template](https://docs.puppet.com/puppet/latest/reference/modules_documentation.html)
  * [YARD Getting Started Guide](http://www.rubydoc.info/gems/yard/file/docs/GettingStarted.md)
  * [YARD Tags Overview](http://www.rubydoc.info/gems/yard/file/docs/Tags.md)

## Developing and Contributing

We love contributions from the community!

If you'd like to contribute to `puppet-strings`, check out [CONTRIBUTING.md](https://github.com/puppetlabs/puppet-strings/blob/master/CONTRIBUTING.md) to get information on the contribution process.

### Running Specs

If you plan on developing features or fixing bugs in Puppet Strings, it is essential that you run specs before opening a pull request.

To run specs, run the `spec` rake task:

    $ bundle install --path .bundle/gems
    $ bundle exec rake spec

## Support

Please log tickets and issues in our [JIRA tracker][JIRA]. A [mailing list](https://groups.google.com/forum/?fromgroups#!forum/puppet-users) is available for asking questions and getting help from others.

There is also an active #puppet channel on the Freenode IRC network.

We use semantic version numbers for our releases and recommend that users upgrade to patch releases and minor releases as they become available.

Bug fixes and ongoing development will occur in minor releases for the current major version. Security fixes will be ported to a previous major version on a best-effort basis, until the previous major version is no longer maintained.
