## 0.6.1

* Updated Android compileSdkVersion to 28 to match other plugins.

## 0.6.0+1

* Log a more detailed warning at build time about the previous AndroidX
  migration.

## 0.6.0

* **Breaking change**. Migrate from the deprecated original Android Support
  Library to AndroidX. This shouldn't result in any functional changes, but it
  requires any Android apps using this plugin to [also
  migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
  using the original support library.

## 0.5.3

* Added missing test package dependency.
* Bumped version of mockito package dependency to pick up Dart 2 support.

## 0.5.2

* Fixes iOS sharing

## 0.5.1

* Updated Gradle tooling to match Android Studio 3.1.2.

## 0.5.0

* **Breaking change**. Namespaced the `share` method inside a `Share` class.
* Fixed crash when sharing on iPad.
* Added functionality to specify share sheet origin on iOS.

## 0.4.0

* **Breaking change**. Set SDK constraints to match the Flutter beta release.

## 0.3.2

* Fixed Dart 2 type error.

## 0.3.1

* Simplified and upgraded Android project template to Android SDK 27.
* Updated package description.

## 0.3.0

* **Breaking change**. Upgraded to Gradle 4.1 and Android Studio Gradle plugin
  3.0.1. Older Flutter projects need to upgrade their Gradle setup as well in
  order to use this version of the plugin. Instructions can be found
  [here](https://github.com/flutter/flutter/wiki/Updating-Flutter-projects-to-Gradle-4.1-and-Android-Studio-Gradle-plugin-3.0.1).

## 0.2.2

* Added FLT prefix to iOS types

## 0.2.1

* Updated README
* Bumped buildToolsVersion to 25.0.3

## 0.2.0

* Upgrade to new plugin registration. (https://groups.google.com/forum/#!topic/flutter-dev/zba1Ynf2OKM)

## 0.1.0

* Initial Open Source release.
