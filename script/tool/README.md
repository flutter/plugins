# Flutter Plugin Tools

Note: The commands in tools are designed to run at the root of the repository or `<repository-root>/packages/`.

To run the tool:

```sh
cd <path_to_plugins>/script/tool && dart pub get && cd ../../
dart run ./script/tool/lib/src/main.dart <args>
```

## Format Code

```sh
cd <path_to_plugins>
dart run /script/tool/lib/src/main.dart format --plugins plugin_name
```

## Run static analyzer

```sh
cd <path_to_plugins>
pub run ./script/tool/lib/src/main.dart analyze --plugins plugin_name
```

## Run Dart unit tests

```sh
cd <path_to_plugins>
pub run ./script/tool/lib/src/main.dart test --plugins plugin_name
```

## Run XCTests

```sh
cd <path_to_plugins>
dart run lib/src/main.dart xctest --target RunnerUITests --skip <plugins_to_skip>
```

## Publish and tag release

``sh
cd <path_to_plugins>
git checkout <commit_hash_to_publish>
dart run ./script/tool/lib/src/main.dart publish-plugin --package <package>
``

By default the tool tries to push tags to the `upstream` remote, but some
additional settings can be configured. Run `dart run ./script/tool/lib/src/main.dart publish-plugin --help` for more usage information.

The tool wraps `pub publish` for pushing the package to pub, and then will
automatically use git to try to create and push tags. It has some additional
safety checking around `pub publish` too. By default `pub publish` publishes
_everything_, including untracked or uncommitted files in version control.
`publish-plugin` will first check the status of the local
directory and refuse to publish if there are any mismatched files with version
control present.

There is a lot about this process that is still to be desired. Some top level
items are being tracked in
[flutter/flutter#27258](https://github.com/flutter/flutter/issues/27258).
