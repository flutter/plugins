## 0.1.0+1

* Added additional exception information from the Flutter framework to the reports.
* Refactored debug printing of exceptions to be human-readable.
* Passing `null` stack traces is now supported.
* Added the "Error reported to Crashlytics." print statement that was previously missing.
* Updated `README.md` to include both the breaking change from `0.1.0` and the newly added
  `recordError` function in the setup section.
* Adjusted `README.md` formatting.
* Fixed `recordFlutterError` method name in the `0.1.0` changelog entry.

## 0.1.0

* **Breaking Change** Renamed `onError` to `recordFlutterError`.
* Added `recordError` method for errors caught using `runZoned`'s `onError`.

## 0.0.4+12

* Update google-services Android gradle plugin to 4.3.0 in documentation and examples.

## 0.0.4+11

* Fixed an issue where `Crashlytics#getStackTraceElements` didn't handle functions without classes.

## 0.0.4+10

* Update README.

## 0.0.4+9

* Fixed custom keys implementation.
* Added tests for custom keys implementation.
* Removed a print statement.

## 0.0.4+8

* Automatically use version from pubspec.yaml when reporting usage to Firebase.

## 0.0.4+7

* Fixed an issue where `Crashlytics#setUserIdentifier` incorrectly called `setUserEmail` on iOS.

## 0.0.4+6

* On Android, use actual the Dart exception name instead of "Dart error."

## 0.0.4+5

* Fix parsing stacktrace.

## 0.0.4+4

* Add missing template type parameter to `invokeMethod` calls.
* Bump minimum Flutter version to 1.5.0.

## 0.0.4+3

* Migrate our handling of `FlutterErrorDetails` to work on both Flutter stable
  and master.

## 0.0.4+2

* Keep debug log formatting.

## 0.0.4+1

* Added an integration test.

## 0.0.4

* Initialize Fabric automatically, preventing crashes that could occur when setting user data.

## 0.0.3

* Rely on firebase_core to add the Android dependency on Firebase instead of hardcoding the version ourselves.

## 0.0.2+1

* Update variable name `enableInDevMode` in README.

## 0.0.2

* Updated the iOS podspec to a static framework to support compatibility with Swift plugins.
* Updated the Android gradle dependencies to prevent build errors.

## 0.0.1

* Initial release of Firebase Crashlytics plugin.
This version reports uncaught errors as non-fatal exceptions in the
Firebase console.
