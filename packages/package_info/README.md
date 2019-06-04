# PackageInfo

This Flutter plugin provides an API for querying information about an
application package.

# Usage

You can use the PackageInfo to query information about the
application package. This works both on iOS and Android.

```dart
import 'package:package_info/package_info.dart';

PackageInfo packageInfo = await PackageInfo.fromPlatform();

String appName = packageInfo.appName;
String packageName = packageInfo.packageName;
String version = packageInfo.version;
String buildNumber = packageInfo.buildNumber;
```

Or in async mode:

```dart
PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
  String appName = packageInfo.appName;
  String packageName = packageInfo.packageName;
  String version = packageInfo.version;
  String buildNumber = packageInfo.buildNumber;
});
```

## IOS-specific Instructions

As noted [here](https://github.com/flutter/flutter/issues/20761), package_info on iOS 
requires the Xcode build folder to be rebuilt after changes to the version string in `pubspec.yaml`. 
Clean the Xcode build folder with: 
`XCode Menu -> Product -> (Holding Option Key) Clean build folder`. 

## Getting Started

For help getting started with Flutter, view our online
[documentation](http://flutter.io/).

For help on editing plugin code, view the [documentation](https://flutter.io/platform-plugins/#edit-code).
