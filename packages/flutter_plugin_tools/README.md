# Flutter Plugin Tools

[![Build Status](https://travis-ci.org/flutter/plugin_tools.svg?branch=master)](https://travis-ci.org/flutter/plugin_tools)
[![pub package](https://img.shields.io/pub/v/flutter_plugin_tools.svg)](https://pub.dartlang.org/packages/flutter_plugin_tools)


Flutter Plugin Tools implements a CLI with various productivity tools for hosting multiple Flutter plugins in one github
repository. It is mainly used by the [flutter/plugins](https://github.com/flutter/plugins) and
[flutter/flutterfire](https://github.com/flutter/flutterfire) repositories. It was mainly written to facilitate
testing on Travis for these repositories (see [.travis.yml](https://github.com/flutter/plugins/blob/master/.travis.yml)).

As an example, Flutter Plugin Tools allows you to:

* Build all plugin example apps with one command
* Run the tests of all plugins with one command
* Format all Dart, Java, Objective-C, and C++ code in the repository
* Define shards of the above tasks

## Installation

In order to use the tools you need to enable them once by running the following command:

```shell
$ pub global activate flutter_plugin_tools
```

## Requirements

To use all features of `flutter_plugin_tools` you'll need the following commands in your `PATH`:
* `flutter`
* `git`
* `pub` (recommended: version from `<path/to/flutter>/bin/cache/dart-sdk/bin`)
* `clang-format` version 5 (alternatively, you can provide the path via `--clang-format=`)
* [`pod`](https://guides.cocoapods.org/using/getting-started.html#installation) (macOS only)

## Usage

```shell
$ pub global run flutter_plugin_tools <command>
$ pub global run flutter_plugin_tools <command> --shardIndex 0 --shardCount 3
```

Run commands from the `flutter/plugins` directory. Replace `<command>` with `help` to print a list of available commands.
The sharded example above divides the plugins into three shards
and executes the tool on the first shard (index 0).
