# Flutter Plugin Tools

This is a set of utilities used in the flutter/plugins and flutter/packages
repositories. It is no longer explictily maintained as a general-purpose tool
for multi-package repositories, so your mileage may vary if using it in other
repositories.

Note: The commands in tools are designed to run at the root of the repository or `<repository-root>/packages/`.

## Getting Started

In flutter/plugins, the tool is run from source. In flutter/packages, the
[published version](https://pub.dev/packages/flutter_plugin_tools) is used
instead. (It is marked as Discontinued since it is no longer maintained as
a general-purpose tool, but updates are still published for use in
flutter/packages.)

The commands in tools require the Flutter-bundled version of Dart to be the first `dart` loaded in the path.

### Extra Setup

When updating sample code excerpts (`update-excerpts`) for the README.md files,
there is some [extra setup for
submodules](#update-readmemd-from-example-sources) that is necessary.

### From Source (flutter/plugins only)

Set up:

```sh
cd ./script/tool && dart pub get && cd ../../
```

Run:

```sh
dart run ./script/tool/bin/flutter_plugin_tools.dart <args>
```

### Published Version

Set up:

```sh
dart pub global activate flutter_plugin_tools
```

Run:

```sh
dart pub global run flutter_plugin_tools <args>
```

## Commands

Run with `--help` for a full list of commands and arguments, but the
following shows a number of common commands being run for a specific plugin.

All examples assume running from source; see above for running the
published version instead.

Most commands take a `--packages` argument to control which package(s) the
command is targetting. An package name can be any of:
- The name of a package (e.g., `path_provider_android`).
- The name of a federated plugin (e.g., `path_provider`), in which case all
  packages that make up that plugin will be targetted.
- A combination federated_plugin_name/package_name (e.g.,
  `path_provider/path_provider` for the app-facing package).

### Format Code

```sh
cd <repository root>
dart run ./script/tool/bin/flutter_plugin_tools.dart format --packages plugin_name
```

### Run the Dart Static Analyzer

```sh
cd <repository root>
dart run ./script/tool/bin/flutter_plugin_tools.dart analyze --packages plugin_name
```

### Run Dart Unit Tests

```sh
cd <repository root>
dart run ./script/tool/bin/flutter_plugin_tools.dart test --packages plugin_name
```

### Run Dart Integration Tests

```sh
cd <repository root>
dart run ./script/tool/bin/flutter_plugin_tools.dart build-examples --apk --packages plugin_name
dart run ./script/tool/bin/flutter_plugin_tools.dart drive-examples --android --packages plugin_name
```

Replace `--apk`/`--android` with the platform you want to test against
(omit it to get a list of valid options).

### Run Native Tests

`native-test` takes one or more platform flags to run tests for. By default it
runs both unit tests and (on platforms that support it) integration tests, but
`--no-unit` or `--no-integration` can be used to run just one type.

Examples:

```sh
cd <repository root>
# Run just unit tests for iOS and Android:
dart run ./script/tool/bin/flutter_plugin_tools.dart native-test --ios --android --no-integration --packages plugin_name
# Run all tests for macOS:
dart run ./script/tool/bin/flutter_plugin_tools.dart native-test --macos --packages plugin_name
# Run all tests for Windows:
dart run ./script/tool/bin/flutter_plugin_tools.dart native-test --windows --packages plugin_name
```

### Update README.md from Example Sources

`update-excerpts` requires sources that are in a submodule. If you didn't clone
with submodules, you will need to `git submodule update --init --recursive`
before running this command.

```sh
cd <repository root>
dart run ./script/tool/bin/flutter_plugin_tools.dart update-excerpts --packages plugin_name
```

### Update CHANGELOG and Version

`update-release-info` will automatically update the version and `CHANGELOG.md`
following standard repository style and practice. It can be used for
single-package updates to handle the details of getting the `CHANGELOG.md`
format correct, but is especially useful for bulk updates across multiple packages.

For instance, if you add a new analysis option that requires production
code changes across many packages:

```sh
cd <repository root>
dart run ./script/tool/bin/flutter_plugin_tools.dart update-release-info \
  --version=minimal \
  --changelog="Fixes violations of new analysis option some_new_option."
```

The `minimal` option for `--version` will skip unchanged packages, and treat
each changed package as either `bugfix` or `next` depending on the files that
have changed in that package, so it is often the best choice for a bulk change.

For cases where you know the change time, `minor` or `bugfix` will make the
corresponding version bump, or `next` will update only `CHANGELOG.md` without
changing the version.

### Publish a Release

**Releases are automated for `flutter/plugins` and `flutter/packages`.**

The manual procedure described here is _deprecated_, and should only be used when
the automated process fails. Please, read
[Releasing a Plugin or Package](https://github.com/flutter/flutter/wiki/Releasing-a-Plugin-or-Package)
on the Flutter Wiki first.

```sh
cd <path_to_plugins>
git checkout <commit_hash_to_publish>
dart run ./script/tool/bin/flutter_plugin_tools.dart publish-plugin --packages <package>
```

By default the tool tries to push tags to the `upstream` remote, but some
additional settings can be configured. Run `dart run ./script/tool/bin/flutter_plugin_tools.dart
publish-plugin --help` for more usage information.

The tool wraps `pub publish` for pushing the package to pub, and then will
automatically use git to try to create and push tags. It has some additional
safety checking around `pub publish` too. By default `pub publish` publishes
_everything_, including untracked or uncommitted files in version control.
`publish-plugin` will first check the status of the local
directory and refuse to publish if there are any mismatched files with version
control present.

## Updating the Tool

For flutter/plugins, just changing the source here is all that's needed.

For changes that are relevant to flutter/packages, you will also need to:
- Update the tool's pubspec.yaml and CHANGELOG
- Publish the tool
- Update the pinned version in
  [flutter/packages](https://github.com/flutter/packages/blob/main/.cirrus.yml)
