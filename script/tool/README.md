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

Note that the `plugins` argument, despite the name, applies to any package.
(It will likely be renamed `packages` in the future.)

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
dart run ./script/tool/bin/flutter_plugin_tools.dart build-examples --packages plugin_name
dart run ./script/tool/bin/flutter_plugin_tools.dart drive-examples --packages plugin_name
```

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
```

### Publish a Release

``sh
cd <path_to_plugins>
git checkout <commit_hash_to_publish>
dart run ./script/tool/bin/flutter_plugin_tools.dart publish-plugin --package <package>
``

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

Automated publishing is under development. Follow
[flutter/flutter#27258](https://github.com/flutter/flutter/issues/27258)
for updates.

## Updating the Tool

For flutter/plugins, just changing the source here is all that's needed.

For changes that are relevant to flutter/packages, you will also need to:
- Update the tool's pubspec.yaml and CHANGELOG
- Publish the tool
- Update the pinned version in
  [flutter/packages](https://github.com/flutter/packages/blob/master/.cirrus.yml)
