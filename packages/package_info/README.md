# package_info

This Flutter plugin provides an API for querying information about an
application package.

# Usage

You can use the `PackageInfo` class to query information about the
application package. This works both on iOS and Android.

```dart
var version = await PackageInfo.getVersion();
var buildNumber = await PackageInfo.getBuildNumber();
```

## Getting Started

For help getting started with Flutter, view our online
[documentation](http://flutter.io/).

For help on editing plugin code, view the [documentation](https://flutter.io/platform-plugins/#edit-code).
