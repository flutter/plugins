## 1.0.0

* Updates version to 1.0 to reflect current status.
* Updates minimum Flutter version to 2.10.
* Updates README to document that on Android, icons may need to be explicitly
  marked as used in the Android project for release builds.
* Minor fixes for new analysis options.

## 0.6.0+11

* Removes unnecessary imports.
* Updates minimum Flutter version to 2.8.
* Adds OS version support information to README.
* Fixes library_private_types_in_public_api, sort_child_properties_last and use_key_in_widget_constructors
  lint warnings.

## 0.6.0+10

* Moves Android and iOS implementations to federated packages.

## 0.6.0+9

* Updates Android compileSdkVersion to 31.
* Updates code for analyzer changes.
* Removes dependency on `meta`.

## 0.6.0+8

* Updates example app Android compileSdkVersion to 31.
* Moves method call to background thread to fix CI failure.

## 0.6.0+7

* Update minimum Flutter SDK to 2.5 and iOS deployment target to 9.0.

## 0.6.0+6

* Updated Android lint settings.
* Fix repository link in pubspec.yaml.

## 0.6.0+5

* Support only calling initialize once.

## 0.6.0+4

* Remove references to the Android V1 embedding.

## 0.6.0+3

* Added a `const` constructor for the `QuickActions` class, so the plugin will behave as documented in the  sample code mentioned in the [README.md](https://github.com/flutter/plugins/blob/59e16a556e273c2d69189b2dcdfa92d101ea6408/packages/quick_actions/quick_actions/README.md).

## 0.6.0+2

* Migrate maven repository from jcenter to mavenCentral.

## 0.6.0+1

* Correctly handle iOS Application lifecycle events on cold start of the App.

## 0.6.0

* Migrate to federated architecture.

## 0.5.0+1

* Updated example app implementation.

## 0.5.0

* Migrate to null safety.
* Fixes quick actions not working on iOS.

## 0.4.0+12

* Fix outdated links across a number of markdown files ([#3276](https://github.com/flutter/plugins/pull/3276))

## 0.4.0+11

* Update Flutter SDK constraint.

## 0.4.0+10

* Update android compileSdkVersion to 29.

## 0.4.0+9

* Keep handling deprecated Android v1 classes for backward compatibility.

## 0.4.0+8

* Update package:e2e -> package:integration_test

## 0.4.0+7

* Update package:e2e reference to use the local version in the flutter/plugins
  repository.

## 0.4.0+6

* Post-v2 Android embedding cleanup.

## 0.4.0+5

* Update lower bound of dart dependency to 2.1.0.

## 0.4.0+4

* Bump the minimum Flutter version to 1.12.13+hotfix.5.
* Clean up various Android workarounds no longer needed after framework v1.12.
* Complete v2 embedding support.
* Fix UIApplicationShortcutItem availability warnings.
* Fix CocoaPods podspec lint warnings.

## 0.4.0+3

* Replace deprecated `getFlutterEngine` call on Android.

## 0.4.0+2

* Make the pedantic dev_dependency explicit.

## 0.4.0+1

* Remove the deprecated `author:` field from pubspec.yaml
* Migrate the plugin to the pubspec platforms manifest.
* Require Flutter SDK 1.10.0 or greater.

## 0.4.0

- Added missing documentation.
- **Breaking change**. `channel` and `withMethodChannel` are now
  `@visibleForTesting`. These methods are for plugin unit tests only and may be
  removed in the future.
- **Breaking change**. Removed `runLaunchAction` from public API. This method
  was not meant to be used by consumers of the plugin.

## 0.3.3+1

* Update and migrate iOS example project by removing flutter_assets, change
  "English" to "en", remove extraneous xcconfigs, update to Xcode 11 build
  settings, and remove ARCHS and DEVELOPMENT_TEAM.

## 0.3.3

* Support Android V2 embedding.
* Add e2e tests.
* Migrate to using the new e2e test binding.

## 0.3.2+4

* Remove AndroidX warnings.

## 0.3.2+3

* Define clang module for iOS.

## 0.3.2+2

* Fix bug that would make the shortcut not open on Android.
* Report shortcut used on Android.
* Improves example.

## 0.3.2+1

* Update usage example in README.

## 0.3.2

* Fixed the quick actions launch on Android when the app is killed.

## 0.3.1

* Added unit tests.

## 0.3.0+2

* Add missing template type parameter to `invokeMethod` calls.
* Bump minimum Flutter version to 1.5.0.
* Replace invokeMethod with invokeMapMethod wherever necessary.

## 0.3.0+1

* Log a more detailed warning at build time about the previous AndroidX
  migration.

## 0.3.0

* **Breaking change**. Migrate from the deprecated original Android Support
  Library to AndroidX. This shouldn't result in any functional changes, but it
  requires any Android apps using this plugin to [also
  migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
  using the original support library.

## 0.2.2

* Allow to register more than once.

## 0.2.1

* Updated Gradle tooling to match Android Studio 3.1.2.

## 0.2.0

* **Breaking change**. Set SDK constraints to match the Flutter beta release.

## 0.1.1

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
