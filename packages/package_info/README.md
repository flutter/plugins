# PackageInfo

This Flutter plugin provides an API for querying information about an
application package.

# Usage

You can use the PackageInfo to query information about the
application package. This works both on iOS and Android.

```dart
import 'package:package_info/package_info.dart';

PackageInfo packageInfo = await PackageInfo.getInstance();

String version = packageInfo.version;
String buildNumber = packageInfo.buildNumber;
String packageName = packageInfo.packageName;
```

## Getting Started

For help getting started with Flutter, view our online
[documentation](http://flutter.io/).

For help on editing plugin code, view the [documentation](https://flutter.io/platform-plugins/#edit-code).
