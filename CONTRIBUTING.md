Contributing to Flutter Plugins
===============================

[![Build Status](https://api.cirrus-ci.com/github/flutter/plugins.svg)](https://cirrus-ci.com/github/flutter/plugins/master)

_See also: [Flutter's code of conduct](https://flutter.io/design-principles/#code-of-conduct)_

Things you will need
--------------------

 * Linux, Mac OS X, or Windows.
 * git (used for source version control).
 * An ssh client (used to authenticate with GitHub).

Getting the code and configuring your environment
-------------------------------------------------

 * Ensure all the dependencies described in the previous section are installed.
 * Fork `https://github.com/flutter/plugins` into your own GitHub account. If
   you already have a fork, and are now installing a development environment on
   a new machine, make sure you've updated your fork so that you don't use stale
   configuration options from long ago.
 * If you haven't configured your machine with an SSH key that's known to github, then
   follow [GitHub's directions](https://help.github.com/articles/generating-ssh-keys/)
   to generate an SSH key.
 * `git clone git@github.com:<your_name_here>/plugins.git`
 * `cd plugins`
 * `git remote add upstream git@github.com:flutter/plugins.git` (So that you
   fetch from the master repository, not your clone, when running `git fetch`
   et al.)

Running the examples
--------------------

To run an example with a prebuilt binary from the cloud, switch to that
example's directory, run `pub get` to make sure its dependencies have been
downloaded, and use `flutter run`. Make sure you have a device connected over
USB and debugging enabled on that device.

 * `cd packages/battery/example`
 * `flutter run`

Running the tests
-----------------

Flutter plugins have both unit tests of their Dart API and integration tests that run on a virtual or actual device.

To run the unit tests:

```
flutter test test/<name_of_plugin>_test.dart
```

To run the integration tests:

```
cd example
flutter drive test/<name_of_plugin>.dart
```

Contributing code
-----------------

We gladly accept contributions via GitHub pull requests.

Please peruse our
[style guide](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo) and
[design principles](https://flutter.io/design-principles/) before
working on anything non-trivial. These guidelines are intended to
keep the code consistent and avoid common pitfalls.

To start working on a patch:

 * `git fetch upstream`
 * `git checkout upstream/master -b <name_of_your_branch>`
 * Hack away.
 * Verify changes with [flutter_plugin_tools](https://pub.dartlang.org/packages/flutter_plugin_tools)
```
pub global activate flutter_plugin_tools
pub global run flutter_plugin_tools format --plugins plugin_name
pub global run flutter_plugin_tools analyze --plugins plugin_name
pub global run flutter_plugin_tools test --plugins plugin_name
```
 * `git commit -a -m "<your informative commit message>"`
 * `git push origin <name_of_your_branch>`

To send us a pull request:

* `git pull-request` (if you are using [Hub](http://github.com/github/hub/)) or
  go to `https://github.com/flutter/plugins` and click the
  "Compare & pull request" button

Please make sure all your checkins have detailed commit messages explaining the patch.

Plugins tests are run automatically on contributions using Cirrus CI. However, due to
cost constraints, pull requests from non-committers may not run all the tests
automatically.

Once you've gotten an LGTM from a project maintainer and once your PR has received
the green light from all our automated testing, wait for one the package maintainers
to merge the pull request and `pub submit` any affected packages.

You must complete the
[Contributor License Agreement](https://cla.developers.google.com/clas).
You can do this online, and it only takes a minute.
If you've never submitted code before, you must add your (or your
organization's) name and contact info to the [AUTHORS](AUTHORS) file.
