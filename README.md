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

1. Install the YARD gem by running `gem install yard`
1. Install the `puppet-strings` gem by running `gem install puppet-strings`
1. **Optional**: Set YARD options for Strings
   
   To use YARD options with Puppet Strings, specify a `yardopts` file in the same directory in which you run `puppet strings`. Puppet Strings supports the Markdown format and automatically sets the YARD `markup` option to `markdown`.
   
   To see a list of available YARD options, run `yard help doc`. For details about YARD options configuration, see the [YARD docs](http://www.rubydoc.info/gems/yard/file/docs/GettingStarted.md#config).

## Generating documentation with Puppet Strings

By default, Puppet Strings outputs documentation as HTML, or you can specify JSON or Markdown output instead.

Strings generates reference documentation based on the code and Strings code comments in all Puppet and Ruby source files under the `./manifests/`, `./functions/`, `./lib/`, `./types/`, and `./tasks/` directories.

Strings outputs HTML of the reference information and the module README to the module's `./doc/` directory. This output can be rendered in any browser.

JSON and Markdown output include the reference documentation only. Strings sends JSON output to either STDOUT or to a file. Markdown output is written to a REFERENCE.md file in the module's main directory.

### Generate documentation in HTML

To generate HTML documentation for a Puppet module, run Strings from that module's directory.

1. Change directory into the module: `cd /modules/<MODULE_NAME>`.
2. Run the command: `puppet strings`.

To generate documentation for specific files or directories in a module, run the `puppet strings generate` subcommand and specify the files or directories as a space-separated list. 

```
puppet strings generate first.pp second.pp
```

To generate documentation for specific directories, run the `puppet strings generate` command and specify the directories:

```
$ puppet strings generate 'modules/foo/lib/**/*.rb' 'modules/foo/manifests/**/*.pp' 'modules/foo/functions/**/*.pp' ...
```
Strings outputs documentation as HTML in a `./doc/` folder in the module. 

You can serve HTML documentation locally with the `server` action. This action serves documentation for all modules in the [module path](https://docs.puppet.com/puppet/latest/reference/dirs_modulepath.html) at `http://localhost:8808`.

To serve documentation locally, run:

```
puppet strings server
```

### Generate documentation in Markdown

Strings outputs documentation in Markdown to a Markdown file in the main directory of the module.

By default, Markdown output generates a `REFERENCE.md` file, but you can specify a different location or filename if you prefer. The generated Markdown includes reference information only. The `REFERENCE.md` file is the same format and information we are introducing into Puppet Supported modules.

1. Change directory into the module: `cd /modules/<MODULE_NAME>`.
2. Run the command: `puppet strings generate --format markdown`.

   To specify a different file, use the `--out` option and specify the path and filename:

   ```
   puppet strings generate --format markdown --out docs/INFO.md
   ```


### Generate documentation in JSON

Strings can generate a JSON file or print JSON to stdout. This can be useful for handling or displaying the data with your own custom applications.

By default, Strings prints JSON output to stdout.

1. Change directory into the module: `cd /modules/<MODULE_NAME>`.
2. Run the command: `puppet strings generate --format json`.

   To generate JSON documentation to a file instead, use the `--out` option and specify a filename:
   
   ```
   puppet strings generate --format json --out documentation.json
   ```

For details about Strings JSON output, see [Strings JSON schema](https://github.com/puppetlabs/puppet-strings/blob/master/JSON.md).


## Publishing documentation to GitHub Pages with Rake tasks

To publish generated HTML documentation to GitHub Pages, set up Rake tasks for Puppet Strings and generate your docs with a Rake task.

The `strings:gh_pages:update` tasks is available in `puppet-strings/tasks`.

This task:

1. Creates a `doc` directory in the root of your project.
1. Creates a `gh-pages` branch of the current repository, if it doesn't already exist.
1. Checks out the `gh-pages` branch of the current repository.
1. Generates Strings documentation.
1. Commits the changes and pushes them to the `gh-pages` branch with the `--force` flag.

This task keeps the `gh-pages` branch up to date with the current code and uses the `--force` option when pushing to the `gh-pages` branch.


1.  Add the following to your Gemfile:

    ```ruby
    gem 'puppet-strings'
    ```

2.  Add the following to your `Rakefile`:

    ```ruby
    require 'puppet-strings/tasks'
    ```
   
    Adding this `require` automatically creates the Rake tasks below.

3. Generate and push your docs by running `strings:gh_pages:update`


## Reference

The `puppet strings` command generates module documentation based on code and code comments. 

By default, running `puppet strings` generates HTML documentation for a module into a `doc/` directory within that module. To pass any options or arguments, use the `generate` action.

Action   | Description   
----------------|-------------------------
`generate` | Generates documentation with the specified parameters, including format and output location.
`server` | Serves documentation for all modules in the [module path](https://docs.puppet.com/puppet/latest/reference/dirs_modulepath.html) locally at `http://localhost:8808`.

### `puppet strings generate` command reference

Usage: `puppet strings [generate] [--format <FORMAT>][--out <DESTINATION>] [<ARGUMENTS>]

For example:

```
puppet strings generate --format markdown --out docs/info.md
```

```
puppet strings generate manifest1.pp manifest2.pp
```

[--format <OUTPUT_FORMAT>][--out <DESTINATION_PATH> [<ARGUMENTS>]

Option   | Description   | Values      | Default
----------------|:---------------:|:------------------:|-------------------------
`--format` | Specifies a format for documentation. | markdown, json    | If not specified, Strings outputs HTML documentation.
`--out` | Specifies an output location for documentation | A valid directory location and filename.    | If not specified, outputs to default locations depending on format: HTML (`/docs/`), Markdown (main module directory), or JSON (stdout).
Filenames or directory paths | Outputs documentation for only specified files or directories. | Markdown, JSON.    | If not specified, Strings outputs HTML documentation.
`--verbose` | Logs verbosely. | none    | If not specified, Strings logs basic information.
`--debug` | Logs debug information. | none    | If not specified, Strings does not log debug information.
`--markup FORMAT` | The markup format to use for docstring text | "markdown", "textile", "rdoc", "ruby", "text", "html", or "none"    | By default, Strings outputs HTML, if no `--format` is specified or Markdown if `--format markdown` is specified.
`--help` | Displays help documentation for the command. | Markdown, JSON    | If not specified, Strings outputs HTML documentation.


# Puppet Strings style

Applies to Puppet 4 and later

Puppet Strings combines source code and code comments to create complete, user-friendly reference information for modules. Strings can generate module documentation for classes, defined types, functions, and resource types in HTML, JSON, and Markdown formats.

Instead of manually writing and formatting long reference lists, add a few descriptive tags and comments for each element (class, defined type, function) of your module. Whenever you update code, update your documentation comments at the same time. Strings automatically extracts some information, such as data types and attribute defaults from the code, so you need to add minimal documentation comments.


## Module README

Module READMEs are where users can learn more about what a module does and how to use it. In the module README, include basic module information and extended usage examples that address common use cases. 

Strings generates complete information about classes, defined types, functions, and resource types and providers. Strings does not yet generate information for type aliases, facts, or custom providers. If your module includes these elements, document them in your README.

The README should contain the following sections:

* Module description: What the module does and why it is useful.
* Setup: Prerequisites for module use and getting started information.
* Usage: Instructions and examples for common use cases or advanced configuration options.
* Reference: If the module contains elements that Strings doesn't document, such as facts or type aliases, include a short Reference section for those elements.
* Limitations: OS compatibility and known issues.
* Development: Guide for contributing to the module.


## Comment style

Generally, Strings documentation comments follow a similar format:

* Comments must immediately precede the code for that element. You cannot have a blank return separating the comment section from the code it documents.
* Each comment tag (such as `@example`) can have more than one line of comments.
* Any additional lines following a tag should be uniformly indented by two spaces.
* Each comment line should be no more than 140 characters, to improve readability.
* Each section (such as `@summary`, `@example`, or the `@param` list) should be followed by a blank comment line to improve readability.
* All untagged comments are output in an overview section that precedes all tagged information for that code element.


### Classes and defined types

Document each class and defined type, along with its parameters, with comments before the code for that class or defined type.

To specify that a class or defined type is private and should not be adjusted by the user, specify the API tag as private: `@api private`.

Class and defined type information should be listed in the following order. 

1. A `@summary` tag with a summary describing the class or defined type. This summary should be 140 characters or fewer. If a class or defined type is deprecated, indicate it here with **Deprecated**.
1. Optional: Other tags such as `@see`, `@note`, or `@api`.
1. Optional: usage examples, each consisting of:
1. An `@example` tag with a description of a usage example on the same line 
1. Code example showing how the class or defined type is used. This example should be directly under the `@example` tag and description, indented two spaces.
1. One `@param` tag for each parameter in the class or defined type. See the parameter section for formatting guidelines.


### Parameters

Add parameter information as part of any class, defined type, or function that accepts parameters.  Parameter information should appear in the following order.

1. The `@param` tag, a space, and then the name of the parameter.
1. Description of what the parameter does. This may be on the same line as the `@param` tag or on the next line.
1. Any additional information about valid values that is not clear from the data type. For example, if the data type is [String], but the value must specifically be a path, say so here.
1. Any other information about the parameter, such as warnings or special behavior.

For example:

```
# @param noselect_servers
#   Specifies one or more peers to not sync with. Puppet appends 'noselect' to each matching item in the `servers` array.
```

#### Example class

```
# This is an example of how to document a Puppet class
#
# @summary configures the Apache PHP module
#
# @example Basic usage
#   class { 'apache::mod::php':
#     package_name => 'mod_php5',
#     source       => '/etc/php/custom_config.conf',
#     php_version  => '7',
#   }
#
# @see http://php.net/manual/en/security.apache.php
#
# @param package_name
#   Names the package that installs mod_php
# @param package_ensure
#   Defines ensure for the PHP module package
# @param path
#   Defines the path to the mod_php shared object (.so) file.
# @param extensions
#   Defines an array of extensions to associate with PHP.
# @param content
#   Adds arbitrary content to php.conf.
# @param template
#   Defines the path to the php.conf template Puppet uses to generate the configuration file.
# @param source
#   Defines the path to the default configuration. Values include a puppet:/// path.
# @param root_group
#   Names a group with root access
# @param php_version
#   Names the PHP version Apache will be using.
#
class apache::mod::php (
  $package_name     = undef,
  $package_ensure   = 'present',
  $path             = undef,
  Array $extensions = ['.php'],
  $content          = undef,
  $template         = 'apache/mod/php.conf.erb',
  $source           = undef,
  $root_group       = $::apache::params::root_group,
  $php_version      = $::apache::params::php_version,
) { … }
```

#### Example defined type

```
# @summary
#   Create and configure a MySQL database.
#
# @example Create a database
#   mysql::db { 'mydb':
#     user     => 'myuser',
#     password => 'mypass',
#     host     => 'localhost',
#     grant    => ['SELECT', 'UPDATE'],
#   }
#
# @param name
#   The name of the database to create. (dbname)
# @param user
#   The user for the database you're creating.
# @param password
#   The password for $user for the database you're creating.
# @param dbname
#   The name of the database to create.
# @param charset
#   The character set for the database.
# @param collate
#   The collation for the database.
# @param host
#   The host to use as part of user@host for grants.
# @param grant
#   The privileges to be granted for user@host on the database.
# @param sql
#   The path to the sqlfile you want to execute. This can be single file specified as string, or it can be an array of strings.
# @param enforce_sql
#   Specifies whether executing the sqlfiles should happen on every run. If set to false, sqlfiles only run once.
# @param ensure
#   Specifies whether to create the database. Valid values are 'present', 'absent'. Defaults to 'present'.
# @param import_timeout
#   Timeout, in seconds, for loading the sqlfiles. Defaults to 300.
# @param import_cat_cmd
#   Command to read the sqlfile for importing the database. Useful for compressed sqlfiles. For example, you can use 'zcat' for .gz files.
#
```



### Functions

Functions must be documented before the function definition, and should include the following information:

An untagged docstring describing what the function does
One `@param` tag for each parameter in the function. See the parameter section for formatting guidelines.
A `@return` tag with the data type and a description of the returned value.
Optionally, a usage example, consisting of:
An `@example` tag with a description of a usage example on the same line 
Code example showing how the function is used. This example should be directly under the `@example` tag and description, indented two spaces.
For custom Ruby functions, docs should come before each ‘dispatch’ call.
For functions in Puppet, docs should be put on top of the function name


#### Ruby function examples

This example has one potential return type

```
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

If there is than one potential return type, you can use the `@return` tag multiple times. In this case, begin each tag string with ‘if’ to differentiate between cases.

```
# An example 4.x function.
Puppet::Functions.create_function(:example) do
  # @param first The first parameter.
  # @param second The second parameter.
  # @return [String] If second argument is less than 10, the name of one item.
  # @return [Array] If second argument is greater than 10, a list of item names.
  # @example Calling the function.
  #   example('hi', 10)
  dispatch :example do
    param 'String', :first
    param 'Integer', :second
  end

  # ...
end
```

#### Puppet function example

```
# An example function written in Puppet.
# @param name the name to say hello to.
# @return [String] Returns a string.
# @example Calling the function.
#    example(‘world’)
function example(String $name) {
    “hello, $name”
}
```


### Resource types

Strings automatically detects much of the information for types, including their parameters and properties. Add descriptions to the type and its attributes by passing either a here document (heredoc) or a short string to the `desc` method.

To document the resource type itself, pass a here document (heredoc) to the `desc` method immediately after the type definition. The heredoc allows you to use String comment tags and multiple lines for your type documentation.

For parameters, where a short description is usually enough, pass a string to `desc` in the attribute. Puppet Strings interprets strings passed to `desc` the same way in interprets the `@param` tag. Like `@param` tag strings, strings passed to `desc` should be no more than 140 characters. If you need a long description for a parameter, you can pass a heredoc to `desc` in the attribute.

Every other method call present in a resource type is automatically included and documented by Strings, and each parameter or property is updated accordingly in the final documentation. This includes method calls such as `defaultto`, `newvalue`, and `namevar`.

If your type dynamically generates parameters or properties, document those attributes with the `@!puppet.type.param` and `@!puppet.type.property` tags before the type definition. These are the only tags you can use before the resource type definition.

The resource type description should appear in the following order:

1. Directly under the type definition, indented two spaces, the `desc` method, with a heredoc including a descriptive delimiting keyword, such as `DESC`.
1. A `@summary` tag with a summary describing the type. This summary should be 140 characters or fewer. 
1. Optionally, usage examples, each consisting of:
   1. An `@example` tag with a description of a usage example on the same line.
   1. Code example showing how the type is used. This example should be directly under the `@example` tag and description, indented two spaces.


#### Example resource type

```
# @!puppet.type.param [value1, value2, value3] my_param Documentation for a dynamic parameter.
# @!puppet.type.property [foo, bar, baz] my_prop Documentation for a dynamic property.
Puppet::Type.newtype(:database) do
  desc <<-DESC
An example resource type.
@example Using the type.
  database { ‘foo’:
    qux => ‘hi’,
  }
DESC

     newproperty(:qux) do
       desc ‘Is a metasyntactic variable’
     end

     newparam(:foo) do`
    desc ‘Is another metasyntactic variable’
    defaultto “THE CLOUD”
  end
end
```

### Resource API type

Document resource API types the same way you would standard resource types, but pass the heredoc or documentation string to a `desc` key in the data structure. You can include tags and multiple lines with the heredoc. Strings pulls the heredoc information along with other information from this data structure.

The heredoc and documentation strings that Strings uses are bolded in this code example:

#### Resource API example

```
Puppet::ResourceApi.register_type(
  name: 'apt_key',
  docs: <<-EOS,
@summary Fancy new type.
@example Fancy new example.
 apt_key { '6F6B15509CF8E59E6E469F327F438280EF8D349F':
   source => 'http://apt.puppetlabs.com/pubkey.gpg'
 }

This type provides Puppet with the capabilities to
manage GPG keys needed by apt to perform package validation. Apt has its own GPG keyring that can be manipulated through the `apt-key` command.

**Autorequires**:
If Puppet is given the location of a key file which looks like an absolute path this type will autorequire that file.
EOS
  attributes:   {
    ensure:      {
      type: 'Enum[present, absent]',
      desc: 'Whether this apt key should be present or absent on the target system.'
    },
    id:          {
      type:      'Variant[Pattern[/\A(0x)?[0-9a-fA-F]{8}\Z/], Pattern[/\A(0x)?[0-9a-fA-F]{16}\Z/], Pattern[/\A(0x)?[0-9a-fA-F]{40}\Z/]]',
      behaviour: :namevar,
      desc:      'The ID of the key you want to manage.',
    },
    # ...
    created:     {
      type:      'String',
      behavior: :read_only,
      desc:      'Date the key was created, in ISO format.',
    },
  },
  autorequires: {
    file:    '$source', # will evaluate to the value of the `source` attribute
    package: 'apt',
  },
)
```

## Tags reference

### Available Strings tags

* `@api`: Describes the resource as private or public, most commonly used with classes or defined types.
* `@example`: Shows an example snippet of code for an object. The first line is an optional title. See above for more about how to [include examples in documentation](#including-examples-in-documentation).
* `@param`: Documents a parameter with a given name, type and optional description.
* `@!puppet.type.param`: Documents dynamic type parameters. See [Documenting resource types and providers](#documenting-resource-types-and-providers) above.
* `@!puppet.type.property`: Documents dynamic type properties. See [Documenting resource types and providers](#documenting-resource-types-and-providers) above.
* `@option`: With a `@param` tag, defines what optional parameters the user can pass in an options hash to the method.
  For example:
  
  ```
  # @param [Hash] opts
  #      List of options
  # @option opts [String] :option1
  #      option 1 in the hash
  # @option opts [Array] :option2
  #      option 2 in the hash
  ```
  
* `@raise`Documents any exceptions that can be raised by the given component. For example: `# @raise PuppetError this error will be raised if x`
* `@return`: Describes the return value (and type or types) of a method. You can list multiple return tags for a method if the method has distinct return cases. In this case, begin each case with "if".
* `@see`: Adds "see also" references. Accepts URLs or other code objects with an optional description at the end. Note that the URL or object is automatically linked by YARD and does not need markup formatting.
* `@since`: Lists the version in which the object was first added.
* `@summary`: A short description of the documented item.


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

We use semantic version numbers for our releases and recommend that users upgrade to
patch releases and minor releases as they become available.

Bug fixes and ongoing development will occur in minor releases for the current major version. Security fixes will be ported to a previous major version on a best-effort basis, until the previous major version is no longer maintained.
