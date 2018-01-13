# package_info

This Flutter plugin provides an API for querying information about an
application package.

# Usage

You can use the package_info package to query information about the
application package. This works both on iOS and Android.

```dart
import 'package:package_info/package_info.dart' as package_info;

var version = await package_info.version;
var buildNumber = await package_info.buildNumber;
var packageName = await package_info.packageName;
```

## Getting Started

For help getting started with Flutter, view our online
[documentation](http://flutter.io/).

For help on editing plugin code, view the [documentation](https://flutter.io/platform-plugins/#edit-code).
