<!-- markdownlint-disable MD024 -->
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v5.0.0](https://github.com/puppetlabs/puppet-strings/tree/v5.0.0) - 2025-06-09

[Full Changelog](https://github.com/puppetlabs/puppet-strings/compare/v4.1.3...v5.0.0)

### Changed

- (CAT-2281) Remove puppet 7 infrastructure [#407](https://github.com/puppetlabs/puppet-strings/pull/407) ([LukasAud](https://github.com/LukasAud))

### Fixed

- Rake task allows for a different commit message [#408](https://github.com/puppetlabs/puppet-strings/pull/408) ([ghoneycutt](https://github.com/ghoneycutt))
- clarifies the puppet-strings usage [#405](https://github.com/puppetlabs/puppet-strings/pull/405) ([binford2k](https://github.com/binford2k))
- List puppet as runtime dependency [#404](https://github.com/puppetlabs/puppet-strings/pull/404) ([bastelfreak](https://github.com/bastelfreak))

## [v4.1.3](https://github.com/puppetlabs/puppet-strings/tree/v4.1.3) - 2024-09-05

[Full Changelog](https://github.com/puppetlabs/puppet-strings/compare/v4.1.2...v4.1.3)

### Fixed

- (bug) - Pin yard to < 0.9.37 [#401](https://github.com/puppetlabs/puppet-strings/pull/401) ([jordanbreen28](https://github.com/jordanbreen28))
- validate: give hint on how to regenerate outdated REFERENCE.md [#388](https://github.com/puppetlabs/puppet-strings/pull/388) ([kenyon](https://github.com/kenyon))
- (CAT-1688) Upgrade rubocop to `~> 1.50.0` [#383](https://github.com/puppetlabs/puppet-strings/pull/383) ([LukasAud](https://github.com/LukasAud))
- Allow numerics for templates using code_maybe_block [#382](https://github.com/puppetlabs/puppet-strings/pull/382) ([seanmil](https://github.com/seanmil))

## [v4.1.2](https://github.com/puppetlabs/puppet-strings/tree/v4.1.2) - 2023-12-05

[Full Changelog](https://github.com/puppetlabs/puppet-strings/compare/v4.1.1...v4.1.2)

### Fixed

- Revert "(maint) - fix rubocop" Leading argument with delegation syntax not supported with ruby 2.7.0 [#376](https://github.com/puppetlabs/puppet-strings/pull/376) ([jordanbreen28](https://github.com/jordanbreen28))

## [v4.1.1](https://github.com/puppetlabs/puppet-strings/tree/v4.1.1) - 2023-11-22

[Full Changelog](https://github.com/puppetlabs/puppet-strings/compare/v4.1.0...v4.1.1)

### Fixed

- Fix option tag handling with no data types [#361](https://github.com/puppetlabs/puppet-strings/pull/361) ([seanmil](https://github.com/seanmil))

## [v4.1.0](https://github.com/puppetlabs/puppet-strings/tree/v4.1.0) - 2023-07-04

[Full Changelog](https://github.com/puppetlabs/puppet-strings/compare/v4.0.0...v4.1.0)

### Added

- (CONT-1193) - Add `--providers` and `--list-providers` flags [#357](https://github.com/puppetlabs/puppet-strings/pull/357) ([jordanbreen28](https://github.com/jordanbreen28))

## [v4.0.0](https://github.com/puppetlabs/puppet-strings/tree/v4.0.0) - 2023-04-25

[Full Changelog](https://github.com/puppetlabs/puppet-strings/compare/v4.0.0.rc.1...v4.0.0)

## [v4.0.0.rc.1](https://github.com/puppetlabs/puppet-strings/tree/v4.0.0.rc.1) - 2023-04-17

[Full Changelog](https://github.com/puppetlabs/puppet-strings/compare/v3.0.1...v4.0.0.rc.1)

### Changed

- (CONT-812) Puppet 8 / Ruby 3 support [#348](https://github.com/puppetlabs/puppet-strings/pull/348) ([chelnak](https://github.com/chelnak))

### Added

- Add deprecated tag [#342](https://github.com/puppetlabs/puppet-strings/pull/342) ([b4ldr](https://github.com/b4ldr))

## [v3.0.1](https://github.com/puppetlabs/puppet-strings/tree/v3.0.1) - 2022-10-25

[Full Changelog](https://github.com/puppetlabs/puppet-strings/compare/v3.0.0...v3.0.1)

### Fixed

- (GH-332) Ensure PuppetStrings is loaded for tasks [#333](https://github.com/puppetlabs/puppet-strings/pull/333) ([chelnak](https://github.com/chelnak))

## [v3.0.0](https://github.com/puppetlabs/puppet-strings/tree/v3.0.0) - 2022-10-21

[Full Changelog](https://github.com/puppetlabs/puppet-strings/compare/v2.9.0...v3.0.0)

### Changed

- (CONT-228) Remove deprecated emit flags [#329](https://github.com/puppetlabs/puppet-strings/pull/329) ([chelnak](https://github.com/chelnak))
- (CONT-228) Bump ruby version [#326](https://github.com/puppetlabs/puppet-strings/pull/326) ([chelnak](https://github.com/chelnak))
- (#301) Update minimum Ruby version to 2.5.0 [#313](https://github.com/puppetlabs/puppet-strings/pull/313) ([danielparks](https://github.com/danielparks))

### Added

- (#223) Use code blocks as appropriate in Markdown [#319](https://github.com/puppetlabs/puppet-strings/pull/319) ([danielparks](https://github.com/danielparks))
- Use tilde heredocs for readability [#317](https://github.com/puppetlabs/puppet-strings/pull/317) ([danielparks](https://github.com/danielparks))

### Fixed

- (#240) Fix output of default values that are expressions [#315](https://github.com/puppetlabs/puppet-strings/pull/315) ([danielparks](https://github.com/danielparks))
- (#267) Don’t show “Public X” header without contents [#314](https://github.com/puppetlabs/puppet-strings/pull/314) ([danielparks](https://github.com/danielparks))
- (#307) Always enable plan parsing [#312](https://github.com/puppetlabs/puppet-strings/pull/312) ([danielparks](https://github.com/danielparks))
- (#302) Fix warnings generated by ERB.new [#308](https://github.com/puppetlabs/puppet-strings/pull/308) ([danielparks](https://github.com/danielparks))
- (#304) Fix double backticks in Markdown [#305](https://github.com/puppetlabs/puppet-strings/pull/305) ([danielparks](https://github.com/danielparks))
- (#300) Fix anchor links in Markdown docs [#303](https://github.com/puppetlabs/puppet-strings/pull/303) ([danielparks](https://github.com/danielparks))

## [v2.9.0](https://github.com/puppetlabs/puppet-strings/tree/v2.9.0) - 2021-11-29

[Full Changelog](https://github.com/puppetlabs/puppet-strings/compare/v2.8.0...v2.9.0)

### Added

- Implement a strings:validate:reference task [#291](https://github.com/puppetlabs/puppet-strings/pull/291) ([ekohl](https://github.com/ekohl))

### Fixed

- Fix rare undefined method `any?' for nil:NilClass error [#289](https://github.com/puppetlabs/puppet-strings/pull/289) ([sanfrancrisko](https://github.com/sanfrancrisko))

## [v2.8.0](https://github.com/puppetlabs/puppet-strings/tree/v2.8.0) - 2021-07-19

[Full Changelog](https://github.com/puppetlabs/puppet-strings/compare/v2.7.0...v2.8.0)

### Added

- (DOCUMENT-1232) Add support for ensurable in types_extras_handler [#281](https://github.com/puppetlabs/puppet-strings/pull/281) ([joshcooper](https://github.com/joshcooper))

### Fixed

- (FIXUP) Check for nil before injecting provider param into Types [#285](https://github.com/puppetlabs/puppet-strings/pull/285) ([scotje](https://github.com/scotje))
- README.md: update link to docs [#276](https://github.com/puppetlabs/puppet-strings/pull/276) ([kenyon](https://github.com/kenyon))

## [v2.7.0](https://github.com/puppetlabs/puppet-strings/tree/v2.7.0) - 2021-05-17

[Full Changelog](https://github.com/puppetlabs/puppet-strings/compare/v2.6.0...v2.7.0)

### Fixed

- Only set tasks = true when parsing plans. [#266](https://github.com/puppetlabs/puppet-strings/pull/266) ([binford2k](https://github.com/binford2k))

## [v2.6.0](https://github.com/puppetlabs/puppet-strings/tree/v2.6.0) - 2021-01-18

[Full Changelog](https://github.com/puppetlabs/puppet-strings/compare/v2.5.0...v2.6.0)

### Changed

- (MAINT) Drop Ruby 2.1.x and Puppet 4.x compatibility [#253](https://github.com/puppetlabs/puppet-strings/pull/253) ([scotje](https://github.com/scotje))

### Added

- Improved markdown templates [#252](https://github.com/puppetlabs/puppet-strings/pull/252) ([kozl](https://github.com/kozl))

### Fixed

- Do not fail in case return tag has no type specified [#268](https://github.com/puppetlabs/puppet-strings/pull/268) ([tiandrey](https://github.com/tiandrey))
- Handle a missing description gracefully [#260](https://github.com/puppetlabs/puppet-strings/pull/260) ([scotje](https://github.com/scotje))
- Fix ERB failure - parameters without descriptions [#255](https://github.com/puppetlabs/puppet-strings/pull/255) ([trevor-vaughan](https://github.com/trevor-vaughan))
- puppet_function template: fix tags, source [#249](https://github.com/puppetlabs/puppet-strings/pull/249) ([raemer](https://github.com/raemer))
- Handle a missing description gracefully [#246](https://github.com/puppetlabs/puppet-strings/pull/246) ([ekohl](https://github.com/ekohl))

## [v2.5.0](https://github.com/puppetlabs/puppet-strings/tree/v2.5.0) - 2020-07-15

[Full Changelog](https://github.com/puppetlabs/puppet-strings/compare/v2.4.0...v2.5.0)

### Added

- (GH-225) Document functions in Puppet Datatypes [#235](https://github.com/puppetlabs/puppet-strings/pull/235) ([glennsarti](https://github.com/glennsarti))
- Add checks to resource_type handler and code objects [#232](https://github.com/puppetlabs/puppet-strings/pull/232) ([scotje](https://github.com/scotje))
- (#227) Inject `provider` into params list for types with providers [#231](https://github.com/puppetlabs/puppet-strings/pull/231) ([scotje](https://github.com/scotje))

### Fixed

- (#242) Wrap names in backticks when rendering to markdown [#243](https://github.com/puppetlabs/puppet-strings/pull/243) ([scotje](https://github.com/scotje))
- Eliminate trailing spaces w/o descriptions [#224](https://github.com/puppetlabs/puppet-strings/pull/224) ([binford2k](https://github.com/binford2k))

## [v2.4.0](https://github.com/puppetlabs/puppet-strings/tree/v2.4.0) - 2020-02-20

[Full Changelog](https://github.com/puppetlabs/puppet-strings/compare/v2.3.1...v2.4.0)

### Added

- Add missing HTML output support for enum tag [#218](https://github.com/puppetlabs/puppet-strings/pull/218) ([seanmil](https://github.com/seanmil))
- (PDOC-295) Add @enum tag support for Enum data types [#215](https://github.com/puppetlabs/puppet-strings/pull/215) ([seanmil](https://github.com/seanmil))
- Expanded default search glob for plans. [#214](https://github.com/puppetlabs/puppet-strings/pull/214) ([Raskil](https://github.com/Raskil))

## [v2.3.1](https://github.com/puppetlabs/puppet-strings/tree/v2.3.1) - 2019-09-23

[Full Changelog](https://github.com/puppetlabs/puppet-strings/compare/v2.3.0...v2.3.1)

### Fixed

- (maint) Use parameters method instead of json['parameters'] [#211](https://github.com/puppetlabs/puppet-strings/pull/211) ([lucywyman](https://github.com/lucywyman))
- (PDOC-285) Fix data_type_handler for errors and numbers [#209](https://github.com/puppetlabs/puppet-strings/pull/209) ([glennsarti](https://github.com/glennsarti))

## [v2.3.0](https://github.com/puppetlabs/puppet-strings/tree/v2.3.0) - 2019-07-17

[Full Changelog](https://github.com/puppetlabs/puppet-strings/compare/v2.2.0...v2.3.0)

### Added

- Add Puppet Data Type documentation [#199](https://github.com/puppetlabs/puppet-strings/pull/199) ([glennsarti](https://github.com/glennsarti))

### Fixed

- (PDOC-283) Fix namespaced symbols [#205](https://github.com/puppetlabs/puppet-strings/pull/205) ([glennsarti](https://github.com/glennsarti))

## [v2.2.0](https://github.com/puppetlabs/puppet-strings/tree/v2.2.0) - 2019-04-05

[Full Changelog](https://github.com/puppetlabs/puppet-strings/compare/v2.1.0...v2.2.0)

### Added

- (PDOC-272) Add required features attribute [#194](https://github.com/puppetlabs/puppet-strings/pull/194) ([kris-bosland](https://github.com/kris-bosland))
- (maint) Implement a strings:generate:reference task [#192](https://github.com/puppetlabs/puppet-strings/pull/192) ([ekohl](https://github.com/ekohl))
- (PDOC-265) Add examples to function reference docs [#188](https://github.com/puppetlabs/puppet-strings/pull/188) ([ekohl](https://github.com/ekohl))
- (PDOC-252) Add describe features to puppet-strings face [#183](https://github.com/puppetlabs/puppet-strings/pull/183) ([kris-bosland](https://github.com/kris-bosland))

### Fixed

- (PDOC-266) Silence 'unexpected construct regexp_literal' warning [#189](https://github.com/puppetlabs/puppet-strings/pull/189) ([seanmil](https://github.com/seanmil))

## [v2.1.0](https://github.com/puppetlabs/puppet-strings/tree/v2.1.0) - 2018-06-26

[Full Changelog](https://github.com/puppetlabs/puppet-strings/compare/2.0.0...v2.1.0)

### Added

- (PDOC-212, PDOC-213) add support for @note and @todo [#182](https://github.com/puppetlabs/puppet-strings/pull/182) ([eputnam](https://github.com/eputnam))
- (PDOC-255) markdown table of contents update [#181](https://github.com/puppetlabs/puppet-strings/pull/181) ([eputnam](https://github.com/eputnam))

### Fixed

- (PDOC-259) relax ruby requirement to 2.1.0 from 2.1.9 [#184](https://github.com/puppetlabs/puppet-strings/pull/184) ([DavidS](https://github.com/DavidS))

## [2.0.0](https://github.com/puppetlabs/puppet-strings/tree/2.0.0) - 2018-05-11

[Full Changelog](https://github.com/puppetlabs/puppet-strings/compare/1.2.1...2.0.0)

### Changed

- bump required ruby and puppet versions [#178](https://github.com/puppetlabs/puppet-strings/pull/178) ([eputnam](https://github.com/eputnam))

### Added

- (PDOC-238) add generated message to markdown [#175](https://github.com/puppetlabs/puppet-strings/pull/175) ([eputnam](https://github.com/eputnam))
- (PDOC-228) puppet plan support [#168](https://github.com/puppetlabs/puppet-strings/pull/168) ([eputnam](https://github.com/eputnam))
- (PDOC-206) support for tasks [#161](https://github.com/puppetlabs/puppet-strings/pull/161) ([eputnam](https://github.com/eputnam))

### Fixed

- (PDOC-36) fix hack for README urls [#176](https://github.com/puppetlabs/puppet-strings/pull/176) ([eputnam](https://github.com/eputnam))
- (PDOC-240) add handling for :array node type in rsapi_handler [#174](https://github.com/puppetlabs/puppet-strings/pull/174) ([eputnam](https://github.com/eputnam))
- (PDOC-159) server urls fix [#173](https://github.com/puppetlabs/puppet-strings/pull/173) ([eputnam](https://github.com/eputnam))
- (maint) display Plans in markdown table of contents [#171](https://github.com/puppetlabs/puppet-strings/pull/171) ([eputnam](https://github.com/eputnam))
- (PDOC-233) markdown whitespace fixes [#170](https://github.com/puppetlabs/puppet-strings/pull/170) ([JohnLyman](https://github.com/JohnLyman))
- (PDOC-229) fix error with return_type and @return [#169](https://github.com/puppetlabs/puppet-strings/pull/169) ([eputnam](https://github.com/eputnam))
- (PDOC-36) hack to fix README links in generated HTML [#167](https://github.com/puppetlabs/puppet-strings/pull/167) ([eputnam](https://github.com/eputnam))
- (PDOC-192) remove warning for title/name [#166](https://github.com/puppetlabs/puppet-strings/pull/166) ([eputnam](https://github.com/eputnam))
- (maint) add condition for misleading warning [#155](https://github.com/puppetlabs/puppet-strings/pull/155) ([eputnam](https://github.com/eputnam))

## [1.2.1](https://github.com/puppetlabs/puppet-strings/tree/1.2.1) - 2018-03-01

[Full Changelog](https://github.com/puppetlabs/puppet-strings/compare/1.2.0...1.2.1)

### Fixed

- (PDOC-224) Handle --emit-json(-stdout) again [#162](https://github.com/puppetlabs/puppet-strings/pull/162) ([ekohl](https://github.com/ekohl))

## [1.2.0](https://github.com/puppetlabs/puppet-strings/tree/1.2.0) - 2018-02-28

[Full Changelog](https://github.com/puppetlabs/puppet-strings/compare/1.1.1...1.2.0)

### Added

- (PDOC-184) generate markdown [#156](https://github.com/puppetlabs/puppet-strings/pull/156) ([eputnam](https://github.com/eputnam))
- (PDK-437) Add support for Resource API types [#153](https://github.com/puppetlabs/puppet-strings/pull/153) ([DavidS](https://github.com/DavidS))

### Fixed

- Fix return type matching for Puppet functions [#159](https://github.com/puppetlabs/puppet-strings/pull/159) ([pegasd](https://github.com/pegasd))
- Add rgen as a runtime dependency [#149](https://github.com/puppetlabs/puppet-strings/pull/149) ([rnelson0](https://github.com/rnelson0))

## [1.1.1](https://github.com/puppetlabs/puppet-strings/tree/1.1.1) - 2017-10-20

[Full Changelog](https://github.com/puppetlabs/puppet-strings/compare/1.1.0...1.1.1)

### Fixed

- (PDOC-160) Remove the timestamp from output [#137](https://github.com/puppetlabs/puppet-strings/pull/137) ([GeoffWilliams](https://github.com/GeoffWilliams))
- Fix args handling for rake strings::generate [#136](https://github.com/puppetlabs/puppet-strings/pull/136) ([hashar](https://github.com/hashar))

## [1.1.0](https://github.com/puppetlabs/puppet-strings/tree/1.1.0) - 2017-03-20

[Full Changelog](https://github.com/puppetlabs/puppet-strings/compare/1.0.0...1.1.0)

### Added

- (PDOC-161) Add `summary` tag for short descriptions [#138](https://github.com/puppetlabs/puppet-strings/pull/138) ([whopper](https://github.com/whopper))
- (PDOC-155) Allow type documentation in Puppet 4 code [#132](https://github.com/puppetlabs/puppet-strings/pull/132) ([whopper](https://github.com/whopper))

## [1.0.0](https://github.com/puppetlabs/puppet-strings/tree/1.0.0) - 2016-11-28

[Full Changelog](https://github.com/puppetlabs/puppet-strings/compare/0.99.0...1.0.0)

### Added

- (PDOC-136) Detect return type syntax in Puppet Language functions [#126](https://github.com/puppetlabs/puppet-strings/pull/126) ([whopper](https://github.com/whopper))
- (PDOC-135) Detect `return_type` calls in 4.x function dispatches [#125](https://github.com/puppetlabs/puppet-strings/pull/125) ([whopper](https://github.com/whopper))
- (PDOC-121) Include tag or SHA in gh_pages task commit [#121](https://github.com/puppetlabs/puppet-strings/pull/121) ([whopper](https://github.com/whopper))
- (PDOC-125) Display all puppet function signatures in top-level signature key [#119](https://github.com/puppetlabs/puppet-strings/pull/119) ([whopper](https://github.com/whopper))

### Fixed

- (PDOC-93) Ensure search bar doesn't overlap item list in nav bar [#123](https://github.com/puppetlabs/puppet-strings/pull/123) ([whopper](https://github.com/whopper))
- (PDOC-129) Include tags in overload objects when serialized as JSON [#122](https://github.com/puppetlabs/puppet-strings/pull/122) ([whopper](https://github.com/whopper))
- (PDOC-126) Remove `%Q` ruby quotation syntax from parsed strings [#118](https://github.com/puppetlabs/puppet-strings/pull/118) ([whopper](https://github.com/whopper))
- (PDOC-127) Strip whitespace from type feature docstrings [#112](https://github.com/puppetlabs/puppet-strings/pull/112) ([whopper](https://github.com/whopper))
- (PDOC-95) Properly group and display multiple provider `defaultfor`s [#111](https://github.com/puppetlabs/puppet-strings/pull/111) ([whopper](https://github.com/whopper))
- (PDOC-122) Properly parse `newfunction` calls with newlines [#110](https://github.com/puppetlabs/puppet-strings/pull/110) ([whopper](https://github.com/whopper))

## [0.99.0](https://github.com/puppetlabs/puppet-strings/tree/0.99.0) - 2016-10-10

[Full Changelog](https://github.com/puppetlabs/puppet-strings/compare/0.4.0...0.99.0)

### Fixed

- (PDOC-80) Remove runtime dependency on puppet [#103](https://github.com/puppetlabs/puppet-strings/pull/103) ([whopper](https://github.com/whopper))
- (PDOC-63) Code refactoring, fix up, and lots of new functionality. [#98](https://github.com/puppetlabs/puppet-strings/pull/98) ([peterhuene](https://github.com/peterhuene))
- (PDOC-71) Workaround for spurious error failures [#90](https://github.com/puppetlabs/puppet-strings/pull/90) ([trevor-vaughan](https://github.com/trevor-vaughan))
- Add Puppet type name in front of the provider name [#80](https://github.com/puppetlabs/puppet-strings/pull/80) ([dmitryilyin](https://github.com/dmitryilyin))

## [0.4.0](https://github.com/puppetlabs/puppet-strings/tree/0.4.0) - 2016-03-30

[Full Changelog](https://github.com/puppetlabs/puppet-strings/compare/0.3.1...0.4.0)

### Fixed

- (PDOC-75) Work with both versions of 'interpret_any' [#77](https://github.com/puppetlabs/puppet-strings/pull/77) ([HAIL9000](https://github.com/HAIL9000))
- (PDOC-70) Always generate the JSON doc when running the rake task [#72](https://github.com/puppetlabs/puppet-strings/pull/72) ([garethr](https://github.com/garethr))
- Fix issue running strings:generate without a yardopts file [#71](https://github.com/puppetlabs/puppet-strings/pull/71) ([garethr](https://github.com/garethr))
- (PDOC-23) Emit json [#55](https://github.com/puppetlabs/puppet-strings/pull/55) ([iankronquist](https://github.com/iankronquist))

## [0.3.1](https://github.com/puppetlabs/puppet-strings/tree/0.3.1) - 2015-09-22

[Full Changelog](https://github.com/puppetlabs/puppet-strings/compare/0.3.0...0.3.1)

### Fixed

- make metadata match pmt output [#65](https://github.com/puppetlabs/puppet-strings/pull/65) ([underscorgan](https://github.com/underscorgan))
- Last PR for the Summer [#62](https://github.com/puppetlabs/puppet-strings/pull/62) ([iankronquist](https://github.com/iankronquist))
- Same name type and provider [#61](https://github.com/puppetlabs/puppet-strings/pull/61) ([iankronquist](https://github.com/iankronquist))

## [0.3.0](https://github.com/puppetlabs/puppet-strings/tree/0.3.0) - 2015-09-21

[Full Changelog](https://github.com/puppetlabs/puppet-strings/compare/0.2.0...0.3.0)

### Added

- Actually/pdoc 19 [#36](https://github.com/puppetlabs/puppet-strings/pull/36) ([iankronquist](https://github.com/iankronquist))
- Type checking/pdoc 21 [#35](https://github.com/puppetlabs/puppet-strings/pull/35) ([iankronquist](https://github.com/iankronquist))
- Dispatch params/pdoc 37 [#33](https://github.com/puppetlabs/puppet-strings/pull/33) ([iankronquist](https://github.com/iankronquist))

### Fixed

- Types and providers fixes [#60](https://github.com/puppetlabs/puppet-strings/pull/60) ([iankronquist](https://github.com/iankronquist))
- (PDOC-35) Format generated html properly [#59](https://github.com/puppetlabs/puppet-strings/pull/59) ([iankronquist](https://github.com/iankronquist))
- (PDOC-49) Improve warnings [#57](https://github.com/puppetlabs/puppet-strings/pull/57) ([iankronquist](https://github.com/iankronquist))
- (PDOC-45) Puppet 4x functions handle unusual names [#53](https://github.com/puppetlabs/puppet-strings/pull/53) ([iankronquist](https://github.com/iankronquist))
- (MAINT) Add a space between a parameter name type and its description [#51](https://github.com/puppetlabs/puppet-strings/pull/51) ([roidelapluie](https://github.com/roidelapluie))
- (PDOC-38) Prevent warnings from being issued twice [#50](https://github.com/puppetlabs/puppet-strings/pull/50) ([iankronquist](https://github.com/iankronquist))
- (PDOC-21) Duplicate warnings [#49](https://github.com/puppetlabs/puppet-strings/pull/49) ([iankronquist](https://github.com/iankronquist))
- (PDOC-21) Only create HostClass parameters once [#48](https://github.com/puppetlabs/puppet-strings/pull/48) ([iankronquist](https://github.com/iankronquist))
- (PDOC-35) Support types and providers [#46](https://github.com/puppetlabs/puppet-strings/pull/46) ([iankronquist](https://github.com/iankronquist))
- (maint) Don't print extraneous "true". [#45](https://github.com/puppetlabs/puppet-strings/pull/45) ([iankronquist](https://github.com/iankronquist))
- (PDOC-21) Check mismatched types in defined types [#44](https://github.com/puppetlabs/puppet-strings/pull/44) ([iankronquist](https://github.com/iankronquist))
- Forgot defined types [#42](https://github.com/puppetlabs/puppet-strings/pull/42) ([iankronquist](https://github.com/iankronquist))
- Nested classes/pdoc 35 [#41](https://github.com/puppetlabs/puppet-strings/pull/41) ([iankronquist](https://github.com/iankronquist))
- (maint) Remove unused code path [#38](https://github.com/puppetlabs/puppet-strings/pull/38) ([iankronquist](https://github.com/iankronquist))
- (PDOC-30) Fix Markdown parsing lists parsing [#37](https://github.com/puppetlabs/puppet-strings/pull/37) ([iankronquist](https://github.com/iankronquist))
- (PDOC-37) Warn when documented name does not match declared name [#31](https://github.com/puppetlabs/puppet-strings/pull/31) ([iankronquist](https://github.com/iankronquist))

## [0.2.0](https://github.com/puppetlabs/puppet-strings/tree/0.2.0) - 2015-03-17

[Full Changelog](https://github.com/puppetlabs/puppet-strings/compare/0.1.1...0.2.0)

### Added

- (PDOC-27) Don't require options for 3x functions [#26](https://github.com/puppetlabs/puppet-strings/pull/26) ([HAIL9000](https://github.com/HAIL9000))
- (PDOC-24) Add basic templates for functions [#22](https://github.com/puppetlabs/puppet-strings/pull/22) ([HAIL9000](https://github.com/HAIL9000))
- (PDOC-17) Add support for YARD tags in puppet code [#21](https://github.com/puppetlabs/puppet-strings/pull/21) ([HAIL9000](https://github.com/HAIL9000))

### Fixed

- Make the metadata match what's generated by the PMT [#28](https://github.com/puppetlabs/puppet-strings/pull/28) ([underscorgan](https://github.com/underscorgan))
- (PDOC-25) Fix mangled puppet namespaces [#27](https://github.com/puppetlabs/puppet-strings/pull/27) ([HAIL9000](https://github.com/HAIL9000))
- (PDOC-26) Rename Puppetx to PuppetX [#25](https://github.com/puppetlabs/puppet-strings/pull/25) ([HAIL9000](https://github.com/HAIL9000))

## [0.1.1](https://github.com/puppetlabs/puppet-strings/tree/0.1.1) - 2014-10-21

[Full Changelog](https://github.com/puppetlabs/puppet-strings/compare/0.1.0...0.1.1)

### Fixed

- (PDOC-14) Fix strings to work with future parser [#19](https://github.com/puppetlabs/puppet-strings/pull/19) ([HAIL9000](https://github.com/HAIL9000))

## [0.1.0](https://github.com/puppetlabs/puppet-strings/tree/0.1.0) - 2014-10-07

[Full Changelog](https://github.com/puppetlabs/puppet-strings/compare/a9408c792ba48ffc5e59d8641a538a83197b7064...0.1.0)
