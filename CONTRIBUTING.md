# How to contribute

Third-party patches are essential for keeping Puppet Strings great. We want to keep it
as easy as possible to contribute changes that get things working in your
environment. There are a few guidelines that we need contributors to follow so
that we can have a chance of keeping on top of things.

## Getting Started

* Make sure you have a [GitHub account](https://github.com/signup/free)
* Submit a ticket for your issue, assuming one does not already exist.
  * Clearly describe the issue including steps to reproduce when it is a bug.
  * Make sure you fill in the earliest version that you know has the issue.
* Fork the repository on GitHub

## Submit an issue

We use GitHub Issues for issue tracking on puppet-strings.

Before you submit your issue, take a minute to...

1. **Use the GitHub issue search** &mdash; check if the issue has already been
   reported.

2. **Check if the issue has been fixed** &mdash; try to reproduce it using the
   latest `master` or release tag.

A good bug report shouldn't leave others needing to chase you up for more
information. Please try to be as **detailed as possible** in your issue. What is
your environment? What steps will reproduce the issue? 

Example:

> Short and descriptive example issue title
>
> A summary of the issue with details about the environment it occurs in (Ruby version, Puppet version, Strings version, etc). If
> suitable, include the steps required to reproduce the bug.
>
> 1. This is the first step
> 2. This is the second step
> 3. Further steps, etc.
>
> Any other information you want to share that is relevant to the issue being
> reported. This might include the lines of code that you have identified as
> causing the bug, and potential solutions (and your opinions on their
> merits).

## Making Changes

* Create a topic branch from where you want to base your work.
  * This is usually the master branch.
  * Only target release branches if you are certain your fix must be on that
    branch.
  * To quickly create a topic branch based on master; `git checkout -b
    fix/master/my_contribution master`. Please avoid working directly on the
    `master` branch.
* Make commits of logical units.
* Check for unnecessary whitespace with `git diff --check` before committing.
* Make sure your commit messages are in the proper format.

````
    (PDOC-123) Make the example in CONTRIBUTING imperative and concrete

    Without this patch applied the example commit message in the CONTRIBUTING
    document is not a concrete example.  This is a problem because the
    contributor is left to imagine what the commit message should look like
    based on a description rather than an example.  This patch fixes the
    problem by making the example concrete and imperative.

    The first line is a real life imperative statement with a ticket number
    from our issue tracker.  The body describes the behavior without the patch,
    why this is a problem, and how the patch fixes the problem when applied.
````

* Make sure you have added the necessary tests for your changes.
* Run _all_ the tests to assure nothing else was accidentally broken.

## Making Trivial Changes

### Documentation

For changes of a trivial nature to comments and documentation, it is not
always necessary to create a new ticket in Jira. In this case, it is
appropriate to start the first line of a commit with '(doc)' instead of
a ticket number.

````
    (doc) Add documentation commit example to CONTRIBUTING

    There is no example for contributing a documentation commit
    to the Puppet repository. This is a problem because the contributor
    is left to assume how a commit of this nature may appear.

    The first line is a real life imperative statement with '(doc)' in
    place of what would have been the ticket number in a
    non-documentation related commit. The body describes the nature of
    the new documentation or comments added.
````

## Submitting Changes

* Sign the [Contributor License Agreement](http://links.puppet.com/cla).
* Push your changes to a topic branch in your fork of the repository.
* Submit a pull request to the repository in the puppetlabs organization.
* Update your Jira ticket to mark that you have submitted code and are ready for it to be reviewed (Status: Ready for Merge).
* Include a link to the pull request in the ticket.
* After feedback has been given we expect responses within two weeks. After two
  weeks will may close the pull request if it isn't showing any activity.

## Cutting a release

To cut a new release, from a current `master` checkout:

* Start the release branch with `git checkout -b release-prep`
* Update `lib/puppet-strings/version.rb` to the new version
* Update the CHANGELOG
  * Have a [CHANGELOG_GITHUB_TOKEN](https://github.com/skywinder/github-changelog-generator#github-token) set in your environment
  * run `rake changelog`
  * double check the PRs to make sure they're all tagged correctly (using the new CHANGELOG for cross-checking)
* Check README and other materials for up-to-date-ness
* Commit changes with title "Release prep for v\<VERSION>"
* Upload and PR the release-prep branch to the puppetlabs GitHub repo
* Check that CI is green and merge the PR
* Run `rake release[upstream]` to release from your checkout
  * make sure to use the name of your git remote pointing to the puppetlabs GitHub repo
* Remove the release-prep branch
* Send the release announcements using the template in [misc/ANNOUNCEMENT_TEMPLATE.md](misc/ANNOUNCEMENT_TEMPLATE.md)

# Additional Resources

* [More information on contributing](http://links.puppet.com/contribute-to-puppet)
* [Contributor License Agreement](http://links.puppet.com/cla)
* [General GitHub documentation](http://help.github.com/)
* [GitHub pull request documentation](http://help.github.com/send-pull-requests/)
