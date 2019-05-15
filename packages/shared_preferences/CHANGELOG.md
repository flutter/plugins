## 0.5.2

* Add containsKey method.

## 0.5.1+2

* Add a driver test

## 0.5.1+1

* Log a more detailed warning at build time about the previous AndroidX
  migration.

## 0.5.1

* Use String to save double in Android.

## 0.5.0

* **Breaking change**. Migrate from the deprecated original Android Support
  Library to AndroidX. This shouldn't result in any functional changes, but it
  requires any Android apps using this plugin to [also
  migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
  using the original support library.

## 0.4.3

* Prevent strings that match special prefixes from being saved. This is a bugfix that prevents apps from accidentally setting special values that would be interpreted incorrectly.

## 0.4.2

* Updated Gradle tooling to match Android Studio 3.1.2.

## 0.4.1

* Added getKeys method.

## 0.4.0

* **Breaking change**. Set SDK constraints to match the Flutter beta release.

## 0.3.3

* Fixed Dart 2 issues.

## 0.3.2

* Added an getter that can retrieve values of any type

## 0.3.1

* Simplified and upgraded Android project template to Android SDK 27.
* Updated package description.

## 0.3.0

* **Breaking change**. Upgraded to Gradle 4.1 and Android Studio Gradle plugin
  3.0.1. Older Flutter projects need to upgrade their Gradle setup as well in
  order to use this version of the plugin. Instructions can be found
  [here](https://github.com/flutter/flutter/wiki/Updating-Flutter-projects-to-Gradle-4.1-and-Android-Studio-Gradle-plugin-3.0.1).

## 0.2.6

* Added FLT prefix to iOS types

## 0.2.5+1

* Aligned author name with rest of repo.

## 0.2.5

* Fixed crashes when setting null values. They now cause the key to be removed.
* Added remove() method

## 0.2.4+1

* Fixed typo in changelog

## 0.2.4

* Added setMockInitialValues
* Added a test
* Updated README

## 0.2.3

* Suppress warning about unchecked operations when compiling for Android

## 0.2.2

* BREAKING CHANGE: setStringSet API changed to setStringList and plugin now supports
  ordered storage.

## 0.2.1

* Support arbitrary length integers for setInt.

## 0.2.0+1

* Updated README

## 0.2.0

* Upgrade to new plugin registration. (https://groups.google.com/forum/#!topic/flutter-dev/zba1Ynf2OKM)

## 0.1.1

* Upgrade Android SDK Build Tools to 25.0.3.

## 0.1.0

* Initial Open Source release.
