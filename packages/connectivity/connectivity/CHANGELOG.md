## 0.4.8+3

* Replace deprecated `getFlutterEngine` call on Android.

## 0.4.8+2

* Remove hard coded ios workspace setting of the example app.

## 0.4.8+1

* Make the pedantic dev_dependency explicit.

## 0.4.8

* Adds macOS as an endorsed platform.

## 0.4.7

* Migrate the plugin to use the ConnectivityPlatform.instance defined in the connectivity_platform_interface package.

## 0.4.6+2

* Migrate deprecated BinaryMessages to ServicesBinding.instance.defaultBinaryMessenger.
* Bump Flutter SDK to 1.12.13+hotfix.5 or greater (current stable).

## 0.4.6+1

* Remove the deprecated `author:` field from pubspec.yaml
* Migrate the plugin to the pubspec platforms manifest.
* Require Flutter SDK 1.10.0 or greater.

## 0.4.6

* Add macOS support.

## 0.4.5+8

* Update documentation to explain when connectivity updates are received on Android.

## 0.4.5+7

* Fix unawaited futures in the example app and tests.

## 0.4.5+6

* Fix singleton Reachability problem on iOS.

## 0.4.5+5

* Add an analyzer check for the public documentation.

## 0.4.5+4

* Stability and Maintainability: update documentations.

## 0.4.5+3

* Remove AndroidX warnings.

## 0.4.5+2

* Include lifecycle dependency as a compileOnly one on Android to resolve
  potential version conflicts with other transitive libraries.

## 0.4.5+1

* Android: Use android.arch.lifecycle instead of androidx.lifecycle:lifecycle in `build.gradle` to support apps that has not been migrated to AndroidX.

## 0.4.5

* Support the v2 Android embedder.

## 0.4.4+1

* Update and migrate iOS example project.
* Define clang module for iOS.

## 0.4.4

* Add `requestLocationServiceAuthorization` to request location authorization on iOS.
* Add `getLocationServiceAuthorization` to get location authorization status on iOS.
* Update README: add more information on iOS 13 updates with CNCopyCurrentNetworkInfo.

## 0.4.3+7

* Update README with the updated information about CNCopyCurrentNetworkInfo on iOS 13.

## 0.4.3+6

* [Android] Fix the invalid suppression check (it should be "deprecation" not "deprecated").

## 0.4.3+5

* [Android] Added API 29 support for `check()`.
* [Android] Suppress warnings for using deprecated APIs.

## 0.4.3+4

* [Android] Updated logic to retrieve network info.

## 0.4.3+3

* Support for TYPE_MOBILE_HIPRI on Android.

## 0.4.3+2

* Add missing template type parameter to `invokeMethod` calls.

## 0.4.3+1

* Fixes lint error by using `getApplicationContext()` when accessing the Wifi Service.

## 0.4.3

* Add getWifiBSSID to obtain current wifi network's BSSID.

## 0.4.2+2

* Add integration test.

## 0.4.2+1

* Bump the minimum Flutter version to 1.2.0.
* Add template type parameter to `invokeMethod` calls.

## 0.4.2

* Adding getWifiIP() to obtain current wifi network's IP.

## 0.4.1

* Add unit tests.

## 0.4.0+2

* Log a more detailed warning at build time about the previous AndroidX
  migration.

## 0.4.0+1

* Updated `Connectivity` to a singleton.

## 0.4.0

* **Breaking change**. Migrate from the deprecated original Android Support
  Library to AndroidX. This shouldn't result in any functional changes, but it
  requires any Android apps using this plugin to [also
  migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
  using the original support library.

## 0.3.2

* Adding getWifiName() to obtain current wifi network's SSID.

## 0.3.1

* Updated Gradle tooling to match Android Studio 3.1.2.

## 0.3.0

* **Breaking change**. Set SDK constraints to match the Flutter beta release.

## 0.2.1

* Fixed warnings from the Dart 2.0 analyzer.
* Simplified and upgraded Android project template to Android SDK 27.
* Updated package description.

## 0.2.0

* **Breaking change**. Upgraded to Gradle 4.1 and Android Studio Gradle plugin
  3.0.1. Older Flutter projects need to upgrade their Gradle setup as well in
  order to use this version of the plugin. Instructions can be found
  [here](https://github.com/flutter/flutter/wiki/Updating-Flutter-projects-to-Gradle-4.1-and-Android-Studio-Gradle-plugin-3.0.1).

## 0.1.1

* Add FLT prefix to iOS types.

## 0.1.0

* Breaking API change: Have a Connectivity class instead of a top level function
* Introduce ability to listen for network state changes

## 0.0.1

* Initial release
