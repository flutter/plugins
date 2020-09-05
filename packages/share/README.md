# Share plugin

[![pub package](https://img.shields.io/pub/v/share.svg)](https://pub.dartlang.org/packages/share)

A Flutter plugin to share content from your Flutter app via the platform's
share dialog.

Wraps the ACTION_SEND Intent on Android and UIActivityViewController
on iOS.

**Please set your constraint to `share: '>=0.6.y+x <2.0.0'`**

## Backward compatible 1.0.0 version is coming
The plugin has reached a stable API, we guarantee that version `1.0.0` will be backward compatible with `0.6.y+z`.
Please use `share: '>=0.6.y+x <2.0.0'` as your dependency constraint to allow a smoother ecosystem migration.
For more details see: https://github.com/flutter/flutter/wiki/Package-migration-to-1.0.0

## Usage

To use this plugin, add `share` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

## Example

Import the library.

``` dart
import 'package:share/share.dart';
```

Then invoke the static `share` method anywhere in your Dart code.

``` dart
Share.share('check out my website https://example.com');
```

The `share` method also takes an optional `subject` that will be used when
sharing to email.

``` dart
Share.share('check out my website https://example.com', subject: 'Look what I made!');
```

To share one or multiple files invoke the static `shareFiles` method anywhere in your Dart code. Optionally you can also pass in `text` and `subject`.
``` dart
Share.shareFiles(['${directory.path}/image.jpg'], text: 'Great picture');
Share.shareFiles(['${directory.path}/image1.jpg', '${directory.path}/image2.jpg']);
```