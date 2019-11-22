# Share plugin

[![pub package](https://img.shields.io/pub/v/share.svg)](https://pub.dartlang.org/packages/share)

A Flutter plugin to share content from your Flutter app via the platform's
share dialog.

Wraps the ACTION_SEND Intent on Android and UIActivityViewController
on iOS.

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
