##2016-10-10 - Release 0.99.0

###Summary

This release includes a complete rewrite of strings, fixing many bugs from previous versions and generally improving the user experience. This release is intended to be the last stop before the strings major version 1.0 is released, and nearly all of the functionality of the major release is included.

All related tickets can be found under the [PDOC][PDOC JIRA] JIRA project with the fix version of [0.99.0](https://tickets.puppetlabs.com/issues/?filter=22705).

###Features
- Complete overhaul, including code cleanup, bug fixes and new functionality **(PDOC-63)**
  - Documentation has been split into sections based on type: puppet 3x API functions, puppet 4x API functions, ruby classes, puppet language functions, types, and providers
  - New JSON schema organized to reflect the separation of types
  - Support for custom functions written in the puppet language
  - Support for puppet function overloads via the create_function 4.x API
  - YARD bumped to latest version, 0.9.5
- Markdown is now the default format for parsing docstring text **(PDOC-86)**
  - Note: this means Markdown text in YARD comments and tags, not a change in the output of strings
- New commandline options: --emit-json and --emit-json-stdout to generate JSON documentation **(PDOC-84)**
- Runtime dependency on Puppet has been removed, allowing strings to function in Puppet Enterprise 3.8 **(PDOC-80)**
  - Note that the gem still requires puppet. We recommend that the strings gem be installed with puppet, as suggested in the  [README](https://github.com/puppetlabs/puppet-strings/blob/master/README.md#installing-puppet-strings)
- New gemspec requirement on Ruby version 1.9.3, the oldest supported Ruby version

###BugFixes

- Prevents a blizzard of errors when documenting Puppet Core source and some puppet modules **(PDOC-63)**
  - As this is a complete rewrite, many known and unknown bugs from the original code were fixed along the way
- Allow strings to be installed in PE 3.8 without overwriting existing puppet and facter installations with newer gems

##2016-03-30 - Release 0.4.0

###Summary

This release adds JSON output support for strings, fixes a major bug that prevented strings from working with the 4.4.0 release of puppet, and is the last version of strings that will be released as a module.

All related tickets can be found under the [PDOC][PDOC JIRA] JIRA project with the fix version of [0.4.0](https://tickets.puppetlabs.com/issues/?filter=18810).

###Features
- Support for JSON output **(PDOC-23)**
  - Strings now has the ability to produce a JSON representation of a given puppet module
  - The details of the JSON schema can be found [here](https://github.com/puppetlabs/puppet-strings/blob/master/json_dom.md)
  - For details on how to generate JSON, see the [README](https://github.com/puppetlabs/puppet-strings/blob/master/README.md#running-puppet-strings)
- Migrate to ruby gems as a distribution method **(PDOC-28)**
  - This is the last release of strings that will be available as a puppet module
  - The 0.4.0 release will be released concurrently as a ruby gem
  - After this release, all updates will only be available via the gem

###Bugfixes

- Fix issue that prevented strings from running with Puppet 4.4.0 **(PDOC-75)**

##2015-09-22 - Release 0.3.1

###Summary

This is a minor bug fix release.

All related tickets can be found under the [PDOC][PDOC JIRA] JIRA project with the fix version of [0.3.1](https://tickets.puppetlabs.com/issues/?filter=15530).

###Bugfixes

- Prevent strings from printing unnecessary quotes in error messages **(PDOC-57)**
- Issue correct type check warnings for defined types **(PDOC-56)**
- Allow providers, types, and defines to have the same name **(PDOC-54)**

##2015-09-21 - Release 0.3.0

###Summary

This release includes support for Puppet Types and Providers, as well as
type checking Puppet 4x functions and defined types.

All related tickets can be found under the [PDOC][PDOC JIRA] JIRA project with
the fix version of [0.3.0](https://tickets.puppetlabs.com/issues/?filter=15529).

####Features

- Support for Puppet Types and Providers **(PDOC-35)**
- Type check Puppet 4x functions and defined types where possible and warn the user when types don't match.
  - Type check defined types **(PDOC-21)**
  - Type check Puppet 4x functions **(PDOC-38)** **(PDOC-19)** **(PDOC-37)**
  - Output type info in generated HTML **(PDOC-19)**
- Improved warnings and logging.
  - Create a consistent style for warnings. **(PDOC-49)**
  - All warnings get printed on stderr.
  - Yard warnings are redirected to a log file **(PDOC-38)**
  - Prevent duplicate warnings **(PDOC-38)**
- Improved README installation and usage instructions.
  - Installation instructions using Puppet **(PDOC-33)**


####Bugfixes

- Fix markdown list processing **(PDOC-30)**
- Fix namespacing for nested classes and defined types **(PDOC-20)**


##2015-03-17 - Release 0.2.0

###Summary

This release includes improvements to the HTML output generated by strings and a few bug fixes.
All related tickets can be found under the [PDOC][PDOC JIRA] JIRA project with the fix version of [0.2.0](https://tickets.puppetlabs.com/issues/?filter=13760).

[PDOC JIRA]: https://tickets.puppetlabs.com/browse/PDOC

####Features
- Custom YARD templates for classes and defined types **(PDOC-17)**
    - Improved HMTL output that is more appropriate for Puppet code (especially for parameters)
    - Support for the explicit list of YARD tags we will be supporting initially (@param, @return, @since, @example)
    - Our own custom YARD templates which can be easily extended and tweaked

- Custom YARD templates for 3.x and 4.x functions **(PDOC-24)**
    - Improved HMTL output that is more appropriate for listing several functions on one webpage in addition to being more consistent with the HTML produced for classes and defined types.
    - Support for the explicit list of YARD tags we will be supporting initially (@param, @return, @since, @example)
    - Our own custom YARD templates which can be easily extended and tweaked
- Addition of RubCop Travis CI job to ensure code quality and consistency **(PDOC-8)**

####Bugfixes
- Puppet namespaces are no longer mangled for nested classes and defined types **(PDOC-25)**
- Strings is now compatible with the renaming of the Puppetx/puppetx namespace to PuppetX/puppet_x **(PDOC-26)**
- Strings will no longer crash when documenting 3x functions with less than two arguments passed into newfunction **(PDOC-27)**

