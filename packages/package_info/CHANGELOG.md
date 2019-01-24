## 0.4.0

* **Breaking change**. Migrate from the deprecated original Android Support
  Library to AndroidX. This shouldn't result in any functional changes, but it
  requires any Android apps using this plugin to [also
  migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
  using the original support library.

## 0.3.2+1

* Fixed a crash on IOS when some of the package infos are not available.

## 0.3.2

* Updated Gradle tooling to match Android Studio 3.1.2.

## 0.3.1

* Added `appName` field to `PackageInfo` for getting the display name of the app.

## 0.3.0

* **Breaking change**. Set SDK constraints to match the Flutter beta release.

## 0.2.1

* Fixed Dart 2 type error.

## 0.2.0

* **Breaking change**. Introduced class `PackageInfo` in place of individual functions.
* `PackageInfo` provides all package information with a single async call.

## 0.1.1

* Added package name to available information.
* Simplified and upgraded Android project template to Android SDK 27.
* Updated package description.

## 0.1.0

* **Breaking change**. Upgraded to Gradle 4.1 and Android Studio Gradle plugin
  3.0.1. Older Flutter projects need to upgrade their Gradle setup as well in
  order to use this version of the plugin. Instructions can be found
  [here](https://github.com/flutter/flutter/wiki/Updating-Flutter-projects-to-Gradle-4.1-and-Android-Studio-Gradle-plugin-3.0.1).

## 0.0.2

* Add FLT prefix to iOS types

## 0.0.1

* Initial release
