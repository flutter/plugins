## 0.6.1+4

* Replace deprecated `getFlutterEngine` call on Android.

## 0.6.1+3

* Make the pedantic dev_dependency explicit.

## 0.6.1+2

* Support v2 embedding.

## 0.6.1+1

* Remove the deprecated `author:` field from pubspec.yaml
* Migrate the plugin to the pubspec platforms manifest.
* Require Flutter SDK 1.10.0 or greater.

## 0.6.1

* Added ability to stop authentication (For Android).

## 0.6.0+3

* Remove AndroidX warnings.

## 0.6.0+2

* Update and migrate iOS example project.
* Define clang module for iOS.

## 0.6.0+1

* Update the `intl` constraint to ">=0.15.1 <0.17.0" (0.16.0 isn't really a breaking change).

## 0.6.0

* Define a new parameter for signaling that the transaction is sensitive.
* Up the biometric version to beta01.
* Handle no device credential error.

## 0.5.3

* Add face id detection as well by not relying on FingerprintCompat.

## 0.5.2+4

* Update README to fix syntax error.

## 0.5.2+3

* Update documentation to clarify the need for FragmentActivity.

## 0.5.2+2

* Add missing template type parameter to `invokeMethod` calls.
* Bump minimum Flutter version to 1.5.0.
* Replace invokeMethod with invokeMapMethod wherever necessary.

## 0.5.2+1
* Use post instead of postDelayed to show the dialog onResume.

## 0.5.2
* Executor thread needs to be UI thread.

## 0.5.1
* Fix crash on Android versions earlier than 28.
* [`authenticateWithBiometrics`](https://pub.dev/documentation/local_auth/latest/local_auth/LocalAuthentication/authenticateWithBiometrics.html) will not return result unless Biometric Dialog is closed.
* Added two more error codes `LockedOut` and `PermanentlyLockedOut`.

## 0.5.0
 * **Breaking change**. Update the Android API to use androidx Biometric package. This gives
   the prompt the updated Material look. However, it also requires the activity to be a
   FragmentActivity. Users can switch to FlutterFragmentActivity in their main app to migrate.

## 0.4.0+1

* Log a more detailed warning at build time about the previous AndroidX
  migration.

## 0.4.0

* **Breaking change**. Migrate from the deprecated original Android Support
  Library to AndroidX. This shouldn't result in any functional changes, but it
  requires any Android apps using this plugin to [also
  migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
  using the original support library.

## 0.3.1
* Fix crash on Android versions earlier than 24.

## 0.3.0

* **Breaking change**. Add canCheckBiometrics and getAvailableBiometrics which leads to a new API.

## 0.2.1

* Updated Gradle tooling to match Android Studio 3.1.2.

## 0.2.0

* **Breaking change**. Set SDK constraints to match the Flutter beta release.

## 0.1.2

* Fixed Dart 2 type error.

## 0.1.1

* Simplified and upgraded Android project template to Android SDK 27.
* Updated package description.

## 0.1.0

* **Breaking change**. Upgraded to Gradle 4.1 and Android Studio Gradle plugin
  3.0.1. Older Flutter projects need to upgrade their Gradle setup as well in
  order to use this version of the plugin. Instructions can be found
  [here](https://github.com/flutter/flutter/wiki/Updating-Flutter-projects-to-Gradle-4.1-and-Android-Studio-Gradle-plugin-3.0.1).

## 0.0.3

* Add FLT prefix to iOS types

## 0.0.2+1

* Update messaging to support Face ID.

## 0.0.2

* Support stickyAuth mode.

## 0.0.1

* Initial release of local authentication plugin.
