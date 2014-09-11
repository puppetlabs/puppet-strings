Puppet Strings
=============

A Puppet Face and plugin built on the [YARD Documentation Tool](http://yardoc.org/) and Puppet Future Parser.

**WARNING: This is very much a science experiment in progress. Things may blow up or change rapidly depending on the Temperature in Portland on a given day.**


Installation
------------

So far, this module has been developed against Puppet 3.6.x.
It will not work with earlier versions.

Currently, just `git clone` directly into the Puppet `modulepath`.
Ensure the `yard` and `rgen` gems are installed.
If running Ruby 1.8.7, ensure the `backports` gem is installed.


Usage
-----

Documenting a module:

    cd /path/to/module
    puppet strings

This processes `README` and everything in `manifests/**/*.pp`.

Documenting specific manifests:

    puppet strings some_manifest.pp [another_if_you_feel_like_it.pp]

Processing is delegated to the `yardoc` tool so some options listed in `yard help doc` are available.
However, Puppet Faces do not support passing arbitrary options through a face so these options must be specified in a `.yardopts` file.


Caveats
-------

  - At the moment, only top-level Classes and Defined Types are parsed and formatted.

  - Documentation blocks must immediately precede the documented code with no whitespace.
    This is because the comment extractor possesses the elegance and intelligance of a bag of hammers.

  - Support for Ruby 1.8.7 may disappear in the future.

  - This is a science experiment. It has a high probability of exploding catastrophically instead of doing something useful.
