# path_provider

[![pub package](https://img.shields.io/pub/v/path_provider.svg)](https://pub.dartlang.org/packages/path_provider)

A Flutter plugin for finding commonly used locations on the filesystem. Supports iOS, Android, Linux and MacOS.
Not all methods are supported on all platforms.

## Usage

To use this plugin, add `path_provider` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

### Example

``` dart
Directory tempDir = await getTemporaryDirectory();
String tempPath = tempDir.path;

Directory appDocDir = await getApplicationDocumentsDirectory();
String appDocPath = appDocDir.path;
```

Please see the example app of this plugin for a full example.

### Usage in tests

Recently `path_provider` was updated to be a federated plugin. 

With that change, tests should be updated to mock `PathProviderPlatform` rather than `PlatformChannel`. 

See this `path_provider` [test](https://github.com/flutter/plugins/blob/master/packages/path_provider/path_provider/test/path_provider_test.dart) for an example.

You will also have to temporarily add the following line to the setup of your test.
```dart
disablePathProviderPlatformOverride = true;
```

See this [issue](https://github.com/flutter/flutter/issues/52267), and these comments [1](https://github.com/flutter/plugins/pull/2789#issuecomment-632354400), [2](https://github.com/flutter/plugins/pull/2789#discussion_r430634873) for details on why this is needed.