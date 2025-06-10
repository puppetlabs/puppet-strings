# Puppet strings

[![ci](https://github.com/voxpupuli/openvox-strings/actions/workflows/ci.yml/badge.svg)](https://github.com/voxpupuli/openvox-strings/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/openvox-strings.svg)](https://badge.fury.io/rb/openvox-strings)

Puppet Strings generates documentation for Puppet code and extensions written in Puppet and Ruby.
Strings processes code and YARD-style code comments to create documentation in HTML, Markdown, or JSON formats.

## Installing Puppet Strings

### Requirements

* Ruby 3.1.0 or newer
* Puppet 8.0.0 or newer

### Install Puppet Strings

Installation instructions vary slightly depending on how you have installed Puppet:

#### Installing Puppet Strings with [`puppet-agent`](https://puppet.com/docs/puppet/6.4/about_agent.html#what-puppet-agent-and-puppetserver-are) package

Install the `openvox-strings` gem into the `puppet-agent` environment:

``` bash
sudo /opt/puppetlabs/puppet/bin/gem install openvox-strings
```

#### Installing Puppet Strings with standalone `openvox` gem

Install the `openvox-strings` gem into the same Ruby installation where you have installed the `openvox` gem:

``` bash
gem install openvox-strings
```

### Configure Puppet Strings (Optional)

To use YARD options with Puppet Strings, specify a `.yardopts` file in the same directory in which you run `puppet strings`.

Puppet Strings supports the Markdown format and automatically sets the YARD `markup` option to `markdown`.

To see a list of available YARD options, run `yard help doc`.

For details about YARD options configuration, see the [YARD docs](http://www.rubydoc.info/gems/yard/file/docs/GettingStarted.md#config).

## Generating documentation with Puppet Strings

By default, Puppet Strings outputs documentation as HTML, or you can specify JSON or Markdown output instead.

Strings generates reference documentation based on the code and Strings code comments in all Puppet and
Ruby source files under the `./manifests/`, `./functions/`, `./lib/`, `./types/`, and `./tasks/` directories.

Strings outputs HTML of the reference information and the module README to the module's `./doc/` directory. This output can be rendered in any browser.

JSON and Markdown output include the reference documentation only.
Strings sends JSON output to either STDOUT or to a file.
Markdown output is written to a REFERENCE.md file in the module's main directory.

See the [Puppet Strings documentation](https://puppet.com/docs/puppet/latest/puppet_strings.html) for complete instructions for generating documentation with Strings.

For code comment style guidelines and examples, see the [Puppet Strings style guide](https://puppet.com/docs/puppet/latest/puppet_strings_style.html).

### Additional Resources

Here are a few other good resources for getting started with documentation:

* [Module README Template](https://puppet.com/docs/puppet/latest/puppet_strings.html)
* [YARD Getting Started Guide](http://www.rubydoc.info/gems/yard/file/docs/GettingStarted.md)
* [YARD Tags Overview](http://www.rubydoc.info/gems/yard/file/docs/Tags.md)

## Developing and Contributing

We love contributions from the community!

If you'd like to contribute to `openvox-strings`, check out [CONTRIBUTING.md](https://github.com/voxpupuli/openvox-strings/blob/main/CONTRIBUTING.md) to get information on the contribution process.

### Running Specs

If you plan on developing features or fixing bugs in Puppet Strings, it is essential that you run specs before opening a pull request.

To run specs, run the `spec` rake task:

``` bash
bundle install --path .bundle/gems
bundle exec rake spec
```

### Running Acceptance Tests

To run specs, run the `acceptance` rake task:

``` bash
bundle install --path .bundle/gems
bundle exec rake acceptance
```

## License

This codebase is licensed under Apache 2.0. However, the open source dependencies included in this codebase might be subject to other software licenses such as AGPL, GPL2.0, and MIT.

## Support

Please log issues in [GitHub issues](https://github.com/voxpupuli/openvox-strings/issues).
Check out [CONTRIBUTING.md](https://github.com/voxpupuli/openvox-strings/blob/main/CONTRIBUTING.md) for tips on writing _the best_ issues.

We use semantic version numbers for our releases and recommend that users upgrade to patch releases and minor releases as they become available.

Bug fixes and ongoing development will occur in minor releases for the current major version.
