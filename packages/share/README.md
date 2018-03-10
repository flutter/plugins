# Share plugin

[![pub package](https://img.shields.io/pub/v/share.svg)](https://pub.dartlang.org/packages/share)

A Flutter plugin to share content from your Flutter app via the platform's
share dialog.

Wraps the ACTION_SEND Intent on Android and UIActivityViewController
on iOS.

## Usage
To use this plugin, add `share` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

## Example

Import the library via
``` dart
import 'package:share/share.dart';
```

Then invoke the static `share` method anywhere in your Dart code
``` dart
share('check out my website https://example.com');
```

## Additional Options on Android
In Android platform you can share text along with an optional title and external file url. What exactly actually gets shared depends on the application the user chooses to complete the action. For example, the optional title is used with applications like Email.

You can also specifiy an optional title for the Share dialog.

``` dart
share('This is the text content' ,
    title: "Check Title" ,
    media: "http://example.com/image.jpg" ,
    dialogTitle: "Love It? Share It!");
```
