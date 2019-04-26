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
