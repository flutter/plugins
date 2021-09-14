## NEXT

* Remove references to the Android v1 embedding.
* Updated Android lint settings.

## 2.0.2

* Update README to point to Plus Plugins version.

## 2.0.1

* Migrate maven repository from jcenter to mavenCentral.

## 2.0.0

* Migrate to null safety.

## 0.4.3+4

* Ensure `IntegrationTestPlugin` is registered in `example` app, so Firebase Test Lab tests report test results correctly. [Issue](https://github.com/flutter/flutter/issues/74944).

## 0.4.3+3

* Update Flutter SDK constraint.

## 0.4.3+2

* Remove unused `test` dependency.
* Update Dart SDK constraint in example.

## 0.4.3+1

* Update android compileSdkVersion to 29.

## 0.4.3

* Update package:e2e -> package:integration_test

## 0.4.2

* Update package:e2e reference to use the local version in the flutter/plugins
  repository.

## 0.4.1

* Add support for macOS.

## 0.4.0+18

* Update lower bound of dart dependency to 2.1.0.

## 0.4.0+17

* Bump the minimum Flutter version to 1.12.13+hotfix.5.
* Clean up various Android workarounds no longer needed after framework v1.12.
* Complete v2 embedding support.
* Fix CocoaPods podspec lint warnings.

## 0.4.0+16

* Declare API stability and compatibility with `1.0.0` (more details at: https://github.com/flutter/flutter/wiki/Package-migration-to-1.0.0).

## 0.4.0+15

* Replace deprecated `getFlutterEngine` call on Android.

## 0.4.0+14

* Make the pedantic dev_dependency explicit.

## 0.4.0+13

* Remove the deprecated `author:` field from pubspec.yaml
* Migrate the plugin to the pubspec platforms manifest.
* Require Flutter SDK 1.10.0 or greater.

## 0.4.0+12

* Fix pedantic lints. This involved internally refactoring how the
  `PackageInfo.fromPlatform` code handled futures, but shouldn't change existing
  functionality.

## 0.4.0+11

* Remove AndroidX warnings.

## 0.4.0+10

* Include lifecycle dependency as a compileOnly one on Android to resolve
  potential version conflicts with other transitive libraries.

## 0.4.0+9

* Android: Use android.arch.lifecycle instead of androidx.lifecycle:lifecycle in `build.gradle` to support apps that has not been migrated to AndroidX.

## 0.4.0+8

* Support the v2 Android embedder.
* Update to AndroidX.
* Add a unit test.
* Migrate to using the new e2e test binding.

## 0.4.0+7

* Update and migrate iOS example project.
* Define clang module for iOS.

## 0.4.0+6

* Fix Android compiler warnings.

## 0.4.0+5

* Add iOS-specific warning to README.md.

## 0.4.0+4

* Add missing template type parameter to `invokeMethod` calls.
* Bump minimum Flutter version to 1.5.0.
* Replace invokeMethod with invokeMapMethod wherever necessary.

## 0.4.0+3

* Add integration test.

## 0.4.0+2

* Android: Using new method for BuildNumber in new android versions

## 0.4.0+1

* Log a more detailed warning at build time about the previous AndroidX
  migration.

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
