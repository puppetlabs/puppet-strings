## 2017-03-20 - Release 1.1.0

### Summary

This release adds a new `summary` tag which can be used to add a short description to classes, functions, types, and providers. In addition, `@param` tags can now include type information in Puppet 4 code without warnings being issued.

All related tickets can be found under the [PDOC](https://tickets.puppetlabs.com/browse/PDOC) JIRA project with the fix version of [1.1.0](https://tickets.puppetlabs.com/issues/?filter=25603).

### Features
- The `summary` tag can be added to any code that puppet-strings supports. The recommended length limit for a summary is 140 characters. Warnings will be issued for strings longer than this limit.
- Puppet 4 parameter types can now be explicitly documented. Previously, this was not allowed because Puppet 4 parameter types can be automatically determined without extra documentation. However, users may desire to do so anyway for consistency. Strings will emit a warning if the documented type does not match the actual type. In such an event, the incorrect documented type will be ignored in favor of the real one.

## 2016-11-28 - Release 1.0.0

### Summary

This release fixes up minor bugs from the 0.99.0 release and modifies the JSON schema for Puppet functions.

All related tickets can be found under the [PDOC](https://tickets.puppetlabs.com/browse/PDOC) JIRA project with the fix version of [1.0.0](https://tickets.puppetlabs.com/issues/?filter=23607).

### Features
- The JSON schema for Puppet functions has been altered to include a new 'signatures' top-level key **(PDOC-125)**
  - Includes information about all function signatures (overloads). Existing overload key format has been preserved.
- Reworked README for enhanced clarity **(PDOC-133)**

### BugFixes
- Fixed an issue where the search box in the code navigator overlapped list items below it **(PDOC-93)**
- Strings can now handle multiple `defaultfor` calls in Puppet providers **(PDOC-95)**
- Fixed an issue preventing the generated \_index.html file from being uploaded to GitHub pages via the gh_pages task **(PDOC-120)**
- Fixed several issues with String's handling of Puppet 3.x and 4.x function return types **(PDOC-135)**, **(PDOC-136)**
- Fixed an issue where String's didn't properly parse overloads if no summary description was provided **(PDOC-129)**
- Strings now correctly handles Puppet 3.x functions when the `newfunction` call is on a newline **(PDOC-122)**
- Fixed an issue where certain Ruby string constructs were incompletely stripped from some docstrings **(PDOC-126)**
- Hanging indents from type feature descriptions are now properly stripped **(PDOC-127)**

## 2016-10-10 - Release 0.99.0

### Summary

This release includes a complete rewrite of strings, fixing many bugs from previous versions and generally improving the user experience. This release is intended to be the last stop before the strings major version 1.0 is released, and nearly all of the functionality of the major release is included.

All related tickets can be found under the [PDOC][PDOC JIRA] JIRA project with the fix version of [0.99.0](https://tickets.puppetlabs.com/issues/?filter=22705).

### Features
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

### BugFixes

- Prevents a blizzard of errors when documenting Puppet Core source and some puppet modules **(PDOC-63)**
  - As this is a complete rewrite, many known and unknown bugs from the original code were fixed along the way
- Allow strings to be installed in PE 3.8 without overwriting existing puppet and facter installations with newer gems

## 2016-03-30 - Release 0.4.0

### Summary

This release adds JSON output support for strings, fixes a major bug that prevented strings from working with the 4.4.0 release of puppet, and is the last version of strings that will be released as a module.

All related tickets can be found under the [PDOC][PDOC JIRA] JIRA project with the fix version of [0.4.0](https://tickets.puppetlabs.com/issues/?filter=18810).

### Features
- Support for JSON output **(PDOC-23)**
  - Strings now has the ability to produce a JSON representation of a given puppet module
  - The details of the JSON schema can be found [here](https://github.com/puppetlabs/puppet-strings/blob/master/json_dom.md)
  - For details on how to generate JSON, see the [README](https://github.com/puppetlabs/puppet-strings/blob/master/README.md#running-puppet-strings)
- Migrate to ruby gems as a distribution method **(PDOC-28)**
  - This is the last release of strings that will be available as a puppet module
  - The 0.4.0 release will be released concurrently as a ruby gem
  - After this release, all updates will only be available via the gem

### Bugfixes

- Fix issue that prevented strings from running with Puppet 4.4.0 **(PDOC-75)**

## 2015-09-22 - Release 0.3.1

### Summary

This is a minor bug fix release.

All related tickets can be found under the [PDOC][PDOC JIRA] JIRA project with the fix version of [0.3.1](https://tickets.puppetlabs.com/issues/?filter=15530).

### Bugfixes

- Prevent strings from printing unnecessary quotes in error messages **(PDOC-57)**
- Issue correct type check warnings for defined types **(PDOC-56)**
- Allow providers, types, and defines to have the same name **(PDOC-54)**

## 2015-09-21 - Release 0.3.0

### Summary

This release includes support for Puppet Types and Providers, as well as
type checking Puppet 4x functions and defined types.

All related tickets can be found under the [PDOC][PDOC JIRA] JIRA project with
the fix version of [0.3.0](https://tickets.puppetlabs.com/issues/?filter=15529).

#### Features

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


#### Bugfixes

- Fix markdown list processing **(PDOC-30)**
- Fix namespacing for nested classes and defined types **(PDOC-20)**


## 2015-03-17 - Release 0.2.0

### Summary

This release includes improvements to the HTML output generated by strings and a few bug fixes.
All related tickets can be found under the [PDOC][PDOC JIRA] JIRA project with the fix version of [0.2.0](https://tickets.puppetlabs.com/issues/?filter=13760).

[PDOC JIRA]: https://tickets.puppetlabs.com/browse/PDOC

#### Features
- Custom YARD templates for classes and defined types **(PDOC-17)**
    - Improved HMTL output that is more appropriate for Puppet code (especially for parameters)
    - Support for the explicit list of YARD tags we will be supporting initially (@param, @return, @since, @example)
    - Our own custom YARD templates which can be easily extended and tweaked

- Custom YARD templates for 3.x and 4.x functions **(PDOC-24)**
    - Improved HMTL output that is more appropriate for listing several functions on one webpage in addition to being more consistent with the HTML produced for classes and defined types.
    - Support for the explicit list of YARD tags we will be supporting initially (@param, @return, @since, @example)
    - Our own custom YARD templates which can be easily extended and tweaked
- Addition of RubCop Travis CI job to ensure code quality and consistency **(PDOC-8)**

#### Bugfixes
- Puppet namespaces are no longer mangled for nested classes and defined types **(PDOC-25)**
- Strings is now compatible with the renaming of the Puppetx/puppetx namespace to PuppetX/puppet_x **(PDOC-26)**
- Strings will no longer crash when documenting 3x functions with less than two arguments passed into newfunction **(PDOC-27)**

