# Contributing to Flutter Plugins

[![Build Status](https://api.cirrus-ci.com/github/flutter/plugins.svg)](https://cirrus-ci.com/github/flutter/plugins/master)

_See also: [Flutter's code of conduct](https://github.com/flutter/flutter/blob/master/CODE_OF_CONDUCT.md)_

## Welcome

For an introduction to contributing to Flutter, see [our contributor
guide](https://github.com/flutter/flutter/blob/master/CONTRIBUTING.md).

Additional resources specific to the plugins repository:
- [Setting up the Plugins development
  environment](https://github.com/flutter/flutter/wiki/Setting-up-the-Plugins-development-environment),
  which covers the setup process for this repository.
- [Plugins repository structure](https://github.com/flutter/flutter/wiki/Plugins-and-Packages-repository-structure),
  to get an overview of how this repository is laid out.
- [Plugin tests](https://github.com/flutter/flutter/wiki/Plugin-Tests), which explains
  the different kinds of tests used for plugins, where to find them, and how to run them.
  As explained in the Flutter guide,
  [**PRs needs tests**](https://github.com/flutter/flutter/wiki/Tree-hygiene#tests), so
  this is critical to read before submitting a PR.
- [Contributing to Plugins and Packages](https://github.com/flutter/flutter/wiki/Contributing-to-Plugins-and-Packages),
  for more information about how to make PRs for this repository, especially when
  changing federated plugins.

## Important note

As of January 2021, we are no longer accepting non-critical PRs for the
[deprecated plugins](./README.md#deprecated), as all new development should
happen in the Flutter Community Plus replacements. If you have a PR for
something other than a critical issue (crashes, build failures, security issues)
in one of those pluigns, please [submit it to the Flutter Community Plus
replacement](https://github.com/fluttercommunity/plus_plugins/pulls) instead.

## Other notes

### Style

Flutter plugins follow Google style—or Flutter style for Dart—for the languages they
use, and use auto-formatters:
- [Dart](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo) formatted
  with `dart format`
- [C++](https://google.github.io/styleguide/cppguide.html) formatted with `clang-format`
  - **Note**: The Linux plugins generally follow idiomatic GObject-based C
    style. See [the engine style
    notes](https://github.com/flutter/engine/blob/master/CONTRIBUTING.md#style)
    for more details, and exceptions.
- [Java](https://google.github.io/styleguide/javaguide.html) formatted with
  `google-java-format`
- [Objective-C](https://google.github.io/styleguide/objcguide.html) formatted with
  `clang-format`

### The review process

Reviewing PRs often requires a non-trivial amount of time. We prioritize issues, not PRs, so that we use our maintainers' time in the most impactful way. Issues pertaining to this repository are managed in the [flutter/flutter issue tracker and are labeled with "plugin"](https://github.com/flutter/flutter/issues?q=is%3Aopen+is%3Aissue+label%3Aplugin+sort%3Areactions-%2B1-desc). Non-trivial PRs should have an associated issue that will be used for prioritization. See the [prioritization section](https://github.com/flutter/flutter/wiki/Issue-hygiene#prioritization) in the Flutter wiki to understand how issues are prioritized.

Newly opened PRs first go through initial triage which results in one of:
  * **Merging the PR** - if the PR can be quickly reviewed and looks good.
  * **Requesting minor changes** - if the PR can be quickly reviewed, but needs changes.
  * **Moving the PR to the backlog** - if the review requires non-trivial effort and the issue isn't currently a priority; in this case the maintainer will:
    * Add the "backlog" label to the issue.
    * Leave a comment on the PR explaining that the review is not trivial and that the issue will be looked at according to priority order.
  * **Starting a non-trivial review** - if the review requires non-trivial effort and the issue is a priority; in this case the maintainer will:
    * Add the "in review" label to the issue.
    * Self assign the PR.
  * **Closing the PR** - if the PR maintainer decides that the PR should not be merged.

Please be aware that there is currently a significant backlog, so reviews for plugin PRs will
in most cases take significantly longer to begin than the two-week timeframe given in the
main Flutter PR guide. An effort is underway to work through the backlog, but it will
take time. If you are interested in hepling out (e.g., by doing initial reviews looking
for obvious problems like missing or failing tests), please reach out
[on Discord](https://github.com/flutter/flutter/wiki/Chat) in `#hackers-ecosystem`.

### Releasing

If you are a team member landing a PR, or just want to know what the release
process is for plugin changes, see [the release
documentation](https://github.com/flutter/flutter/wiki/Releasing-a-Plugin-or-Package).
