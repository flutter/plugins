# share

A Flutter plugin to share content from your Flutter app via the platform's
share dialog.

Wraps the ACTION_SEND Intent on Android and UIActivityViewController
on iOS.

## Usage

To use, first add `share` as a [dependency in your pubspec.yaml](https://flutter.io/platform-plugins/).
```yaml
dependencies:
  flutter:
    sdk: flutter
  share: ^0.1.0
```

Import the library via
```dart
import 'package:share/share.dart';
```

Then invoke the static `share` method anywhere in your Dart code
```dart
share('check out my website https://example.com');
```
