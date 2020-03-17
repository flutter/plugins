## 0.6.3+8

* Replace deprecated `getFlutterEngine` call on Android.

## 0.6.3+7

* Updated gradle version of example.

## 0.6.3+6

* Make the pedantic dev_dependency explicit.

## 0.6.3+5

* Remove the deprecated `author:` field from pubspec.yaml
* Migrate the plugin to the pubspec platforms manifest.
* Require Flutter SDK 1.10.0 or greater.

## 0.6.3+4

* Fix pedantic lints. This shouldn't affect existing functionality.

## 0.6.3+3

* README update.

## 0.6.3+2

* Remove AndroidX warnings.

## 0.6.3+1

* Include lifecycle dependency as a compileOnly one on Android to resolve
  potential version conflicts with other transitive libraries.

## 0.6.3

* Support the v2 Android embedder.
* Update to AndroidX.
* Migrate to using the new e2e test binding.
* Add a e2e test.

## 0.6.2+4

* Define clang module for iOS.

## 0.6.2+3

* Fix iOS crash when setting subject to null.

## 0.6.2+2

* Update and migrate iOS example project.

## 0.6.2+1

* Specify explicit type for `invokeMethod`.
* Use `const` for `Rect`.
* Updated minimum Flutter SDK to 1.6.0.

## 0.6.2

* Add optional subject to fill email subject in case user selects email app.

## 0.6.1+2

* Update Dart code to conform to current Dart formatter.

## 0.6.1+1

* Fix analyzer warnings about `const Rect` in tests.

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
