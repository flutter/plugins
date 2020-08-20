## 0.5.10

* Update package:e2e -> package:integration_test

## 0.5.9

* Update package:e2e reference to use the local version in the flutter/plugins
  repository.

## 0.5.8

* Support Linux by default.

## 0.5.7+3

* Post-v2 Android embedding cleanup.

## 0.5.7+2

* Update lower bound of dart dependency to 2.1.0.

## 0.5.7+1

* Declare API stability and compatibility with `1.0.0` (more details at: https://github.com/flutter/flutter/wiki/Package-migration-to-1.0.0).

## 0.5.7

* Remove Android dependencies fallback.
* Require Flutter SDK 1.12.13+hotfix.5 or greater.
* Fix CocoaPods podspec lint warnings.

## 0.5.6+3

* Fix deprecated API usage warning.

## 0.5.6+2

* Make the pedantic dev_dependency explicit.

## 0.5.6+1

* Updated README

## 0.5.6

* Support `web` by default.
* Require Flutter SDK 1.12.13+hotfix.4 or greater.

## 0.5.5

* Support macos by default.

## 0.5.4+10

* Adds a `shared_preferences_macos` package.

## 0.5.4+9

* Remove the deprecated `author:` field from pubspec.yaml
* Migrate the plugin to the pubspec platforms manifest.
* Require Flutter SDK 1.10.0 or greater.

## 0.5.4+8

* Switch `package:shared_preferences` to `package:shared_preferences_platform_interface`.
  No code changes are necessary in Flutter apps. This is not a breaking change.

## 0.5.4+7

* Restructure the project for Web support.

## 0.5.4+6

* Add missing documentation and a lint to prevent further undocumented APIs.

## 0.5.4+5

* Update and migrate iOS example project by removing flutter_assets, change
  "English" to "en", remove extraneous xcconfigs and framework outputs,
  update to Xcode 11 build settings, and remove ARCHS.

## 0.5.4+4

* `setMockInitialValues` needs to handle non-prefixed keys since that's an implementation detail.

## 0.5.4+3

* Android: Suppress casting warnings.

## 0.5.4+2

* Remove AndroidX warnings.

## 0.5.4+1

* Include lifecycle dependency as a compileOnly one on Android to resolve
  potential version conflicts with other transitive libraries.

## 0.5.4

* Support the v2 Android embedding.
* Update to AndroidX.
* Migrate to using the new e2e test binding.

## 0.5.3+5

* Define clang module for iOS.

## 0.5.3+4

* Copy `List` instances when reading and writing values to prevent mutations from propagating.

## 0.5.3+3

* `setMockInitialValues` can now be called multiple times and will
  `reload()` the singleton if necessary.

## 0.5.3+2

* Fix Gradle version.

## 0.5.3+1

* Add missing template type parameter to `invokeMethod` calls.
* Bump minimum Flutter version to 1.5.0.
* Replace invokeMethod with invokeMapMethod wherever necessary.

## 0.5.3

* Add reload method.

## 0.5.2+2

* Updated Gradle tooling to match Android Studio 3.4.

## 0.5.2+1

* .commit() calls are now run in an async background task on Android.

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
