## NEXT

* Updates minimum Flutter version to 2.10.

## 2.1.2

* Fixes avoid_redundant_argument_values lint warnings and minor typos.

## 2.1.1

* Replaces `USE_FINGERPRINT` permission with `USE_BIOMETRIC` in README and example project.

## 2.1.0

* Adds Windows support.

## 2.0.2

* Fixes library_private_types_in_public_api, sort_child_properties_last and use_key_in_widget_constructors
  lint warnings.

## 2.0.1

* Restores the ability to import `error_codes.dart`.
* Updates README to match API changes in 2.0, and to improve clarity in
  general.
* Removes unnecessary imports.

## 2.0.0

* Migrates plugin to federated architecture.
* Adds OS version support information to README.
* BREAKING CHANGE: Deprecated method `authenticateWithBiometrics` has been removed.
  Use `authenticate` instead.
* BREAKING CHANGE: Enum `BiometricType` has been expanded with options for `strong` and `weak`,
  and applications should be updated to handle these accordingly.
* BREAKING CHANGE: Parameters of `authenticate` have been changed.

  Example:
  ```dart
  // Old way of calling `authenticate`.
  Future<bool> authenticate(
    localizedReason: 'localized reason',
    useErrorDialogs: true,
    stickyAuth: false,
    androidAuthStrings: const AndroidAuthMessages(),
    iOSAuthStrings: const IOSAuthMessages(),
    sensitiveTransaction: true,
    biometricOnly: false,
  );
  // New way of calling `authenticate`.
  Future<bool> authenticate(
    localizedReason: 'localized reason',
    authMessages: const <AuthMessages>[
      IOSAuthMessages(),
      AndroidAuthMessages()
    ],
    options: const AuthenticationOptions(
      useErrorDialogs: true,
      stickyAuth: false,
      sensitiveTransaction: true,
      biometricOnly: false,
    ),
  );
  ```



## 1.1.11

* Adds support `localizedFallbackTitle` in authenticateWithBiometrics on iOS.

## 1.1.10

* Removes dependency on `meta`.

## 1.1.9

* Updates code for analysis option changes.
* Updates Android compileSdkVersion to 31.

## 1.1.8

* Update minimum Flutter SDK to 2.5 and iOS deployment target to 9.0.
* Updated Android lint settings.

## 1.1.7

* Remove references to the Android V1 embedding.

## 1.1.6

* Migrate maven repository from jcenter to mavenCentral.

## 1.1.5

* Updated grammatical errors and inaccurate information in README.

## 1.1.4

* Add debug assertion that `localizedReason` in `LocalAuthentication.authenticateWithBiometrics`  must not be empty.

## 1.1.3

* Fix crashes due to threading issues in iOS implementation.

## 1.1.2

* Update Jetpack dependencies to latest stable versions.

## 1.1.1

* Update flutter_plugin_android_lifecycle dependency to 2.0.1 to fix an R8 issue
  on some versions.

## 1.1.0

* Migrate to null safety.
* Allow pin, passcode, and pattern authentication with `authenticate` method.
* Fix incorrect error handling switch case fallthrough.
* Update README for Android Integration.
* Update the example app: remove the deprecated `RaisedButton` and `FlatButton` widgets.
* Fix outdated links across a number of markdown files ([#3276](https://github.com/flutter/plugins/pull/3276)).
* **Breaking change**. Parameter names refactored to use the generic `biometric` prefix in place of `fingerprint` in the `AndroidAuthMessages` class
  * `fingerprintHint` is now `biometricHint`
  * `fingerprintNotRecognized`is now `biometricNotRecognized`
  * `fingerprintSuccess`is now `biometricSuccess`
  * `fingerprintRequiredTitle` is now `biometricRequiredTitle`

## 0.6.3+5

* Update Flutter SDK constraint.

## 0.6.3+4

* Update Dart SDK constraint in example.

## 0.6.3+3

* Update android compileSdkVersion to 29.

## 0.6.3+2

* Keep handling deprecated Android v1 classes for backward compatibility.

## 0.6.3+1

* Update package:e2e -> package:integration_test

## 0.6.3

* Increase upper range of `package:platform` constraint to allow 3.X versions.

## 0.6.2+4

* Update package:e2e reference to use the local version in the flutter/plugins
  repository.

## 0.6.2+3

* Post-v2 Android embedding cleanup.

## 0.6.2+2

* Update lower bound of dart dependency to 2.1.0.

## 0.6.2+1

* Fix CocoaPods podspec lint warnings.

## 0.6.2

* Remove Android dependencies fallback.
* Require Flutter SDK 1.12.13+hotfix.5 or greater.
* Fix block implicitly retains 'self' warning.

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
