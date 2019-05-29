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
