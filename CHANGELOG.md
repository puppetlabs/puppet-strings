# Changelog

All significant changes to this repo will be summarized in this file.


## [v2.4.0](https://github.com/puppetlabs/puppet-strings/tree/v2.4.0) (2020-02-18)

[Full Changelog](https://github.com/puppetlabs/puppet-strings/compare/v2.3.1...v2.4.0)

Added

- Add missing HTML output support for enum tag [\#218](https://github.com/puppetlabs/puppet-strings/pull/218) ([seanmil](https://github.com/seanmil))
- \(PDOC-295\) Add @enum tag support for Enum data types [\#215](https://github.com/puppetlabs/puppet-strings/pull/215) ([seanmil](https://github.com/seanmil))
- Expanded default search glob for plans. [\#214](https://github.com/puppetlabs/puppet-strings/pull/214) ([Raskil](https://github.com/Raskil))

## [v2.3.1](https://github.com/puppetlabs/puppet-strings/tree/v2.3.1) (2019-09-23)

[Full Changelog](https://github.com/puppetlabs/puppet-strings/compare/v2.3.0...v2.3.1)

Fixed

- \(maint\) Use parameters method instead of json\['parameters'\] [\#211](https://github.com/puppetlabs/puppet-strings/pull/211) ([lucywyman](https://github.com/lucywyman))
- \(PDOC-285\) Fix data\_type\_handler for errors and numbers [\#209](https://github.com/puppetlabs/puppet-strings/pull/209) ([glennsarti](https://github.com/glennsarti))

## [v2.3.0](https://github.com/puppetlabs/puppet-strings/tree/v2.3.0) (2019-07-17)

[Full Changelog](https://github.com/puppetlabs/puppet-strings/compare/v2.2.0...v2.3.0)

Added

- Add Puppet Data Type documentation [\#199](https://github.com/puppetlabs/puppet-strings/pull/199) ([glennsarti](https://github.com/glennsarti))

Fixed

- \(PDOC-283\) Fix namespaced symbols [\#205](https://github.com/puppetlabs/puppet-strings/pull/205) ([glennsarti](https://github.com/glennsarti))

## [v2.2.0](https://github.com/puppetlabs/puppet-strings/tree/v2.2.0) (2019-04-05)

[Full Changelog](https://github.com/puppetlabs/puppet-strings/compare/v2.1.0...v2.2.0)

Added

- \(PDOC-272\) Add required features attribute [\#194](https://github.com/puppetlabs/puppet-strings/pull/194) ([kris-bosland](https://github.com/kris-bosland))
- \(maint\) Implement a strings:generate:reference task [\#192](https://github.com/puppetlabs/puppet-strings/pull/192) ([ekohl](https://github.com/ekohl))
- \(PDOC-265\) Add examples to function reference docs [\#188](https://github.com/puppetlabs/puppet-strings/pull/188) ([ekohl](https://github.com/ekohl))
- \(PDOC-252\) Add describe features to puppet-strings face [\#183](https://github.com/puppetlabs/puppet-strings/pull/183) ([kris-bosland](https://github.com/kris-bosland))

Fixed

- \(PDOC-266\) Silence 'unexpected construct regexp\_literal' warning [\#189](https://github.com/puppetlabs/puppet-strings/pull/189) ([seanmil](https://github.com/seanmil))

## [v2.1.0](https://github.com/puppetlabs/puppet-strings/tree/v2.1.0) (2018-06-26)

[Full Changelog](https://github.com/puppetlabs/puppet-strings/compare/2.0.0...v2.1.0)

Added

- \(PDOC-212, PDOC-213\) add support for @note and @todo [\#182](https://github.com/puppetlabs/puppet-strings/pull/182) ([eputnam](https://github.com/eputnam))
- \(PDOC-255\) markdown table of contents update [\#181](https://github.com/puppetlabs/puppet-strings/pull/181) ([eputnam](https://github.com/eputnam))

Fixed

- \(PDOC-259\) relax ruby requirement to 2.1.0 from 2.1.9 [\#184](https://github.com/puppetlabs/puppet-strings/pull/184) ([DavidS](https://github.com/DavidS))

# Previous Changes

## [2.0.0](https://github.com/puppetlabs/puppet-strings/tree/2.0.0) (2018-05-11)

[Full Changelog](https://github.com/puppetlabs/puppet-strings/compare/1.2.1...2.0.0)

### Changed

- bump required ruby and puppet versions [\#178](https://github.com/puppetlabs/puppet-strings/pull/178) ([eputnam](https://github.com/eputnam))

### Added

- \(PDOC-238\) add generated message to markdown [\#175](https://github.com/puppetlabs/puppet-strings/pull/175) ([eputnam](https://github.com/eputnam))
- \(PDOC-228\) puppet plan support [\#168](https://github.com/puppetlabs/puppet-strings/pull/168) ([eputnam](https://github.com/eputnam))
- \(PDOC-206\) support for tasks [\#161](https://github.com/puppetlabs/puppet-strings/pull/161) ([eputnam](https://github.com/eputnam))

### Fixed

- \(PDOC-36\) fix hack for README urls [\#176](https://github.com/puppetlabs/puppet-strings/pull/176) ([eputnam](https://github.com/eputnam))
- \(PDOC-240\) add handling for :array node type in rsapi\_handler [\#174](https://github.com/puppetlabs/puppet-strings/pull/174) ([eputnam](https://github.com/eputnam))
- \(PDOC-159\) server urls fix [\#173](https://github.com/puppetlabs/puppet-strings/pull/173) ([eputnam](https://github.com/eputnam))
- \(maint\) display Plans in markdown table of contents [\#171](https://github.com/puppetlabs/puppet-strings/pull/171) ([eputnam](https://github.com/eputnam))
- \(PDOC-233\) markdown whitespace fixes [\#170](https://github.com/puppetlabs/puppet-strings/pull/170) ([JohnLyman](https://github.com/JohnLyman))
- \(PDOC-229\) fix error with return\_type and @return [\#169](https://github.com/puppetlabs/puppet-strings/pull/169) ([eputnam](https://github.com/eputnam))
- \(PDOC-36\) hack to fix README links in generated HTML [\#167](https://github.com/puppetlabs/puppet-strings/pull/167) ([eputnam](https://github.com/eputnam))
- \(PDOC-192\) remove warning for title/name [\#166](https://github.com/puppetlabs/puppet-strings/pull/166) ([eputnam](https://github.com/eputnam))
- \(maint\) add condition for misleading warning [\#155](https://github.com/puppetlabs/puppet-strings/pull/155) ([eputnam](https://github.com/eputnam))

## [1.2.1](https://github.com/puppetlabs/puppet-strings/tree/1.2.1) (2018-03-01)

[Full Changelog](https://github.com/puppetlabs/puppet-strings/compare/1.2.0...1.2.1)

### Fixed

- (PDOC-224) Handle --emit-json(-stdout) again [\#162](https://github.com/puppetlabs/puppet-strings/pull/162) ([ekohl](https://github.com/ekohl))

## [1.2.0](https://github.com/puppetlabs/puppet-strings/tree/1.2.0) (2018-02-26)

[Full Changelog](https://github.com/puppetlabs/puppet-strings/compare/1.1.1...1.2.0)

### Added

- \(PDOC-184\) generate markdown [\#156](https://github.com/puppetlabs/puppet-strings/pull/156) ([eputnam](https://github.com/eputnam))
- \(PDK-437\) Add support for Resource API types [\#153](https://github.com/puppetlabs/puppet-strings/pull/153) ([DavidS](https://github.com/DavidS))

### Fixed

- Fix return type matching for Puppet functions [\#159](https://github.com/puppetlabs/puppet-strings/pull/159) ([pegasd](https://github.com/pegasd))
- Add rgen as a runtime dependency [\#149](https://github.com/puppetlabs/puppet-strings/pull/149) ([rnelson0](https://github.com/rnelson0))

## 2017-10-20 - Release 1.1.1

### BugFixes
- Remove timestamps from footer of generated HTML pages ([GeoffWilliams](https://github.com/GeoffWilliams))
- Fix argument handling for `rake strings::generate` ([hashar](https://github.com/hashar))

### Other
- Fixed Markdown formatting issues in CHANGELOG ([maju6406](https://github.com/maju6406))
- Fixed typo in README ([hfm](https://github.com/hfm))
- Fixed Markdown formatting issues in README ([gguillotte](https://github.com/gguillotte))
- Update Travis CI configurations for Ruby and Puppet versions ([ghoneycutt](https://github.com/ghoneycutt))

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


\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*
