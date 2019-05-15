## 3.0.0

* Update Android dependencies to latest.

## 2.0.3

* Provide a `toString` implementation for `DatabaseError`.

## 2.0.2+1

* Added an integration test for transactions.

## 2.0.2

* Fix the issue that `getDictionaryFromError` always returns non nil result even when the parameter is nil.

## 2.0.1+3

* Fixing DatabaseReference.set unhandled exception which happened when a successful operation was performed.

## 2.0.1+2

* Log messages about automatic configuration of the default app are now less confusing.

## 2.0.1+1

* Remove categories.

## 2.0.1

* Log a more detailed warning at build time about the previous AndroidX
  migration.

## 2.0.0

* **Breaking change**. Migrate from the deprecated original Android Support
  Library to AndroidX. This shouldn't result in any functional changes, but it
  requires any Android apps using this plugin to [also
  migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
  using the original support library.

  This was originally incorrectly pushed in the `1.1.0` update.

## 1.1.0+1

* **Revert the breaking 1.1.0 update**. 1.1.0 was known to be breaking and
  should have incremented the major version number instead of the minor. This
  revert is in and of itself breaking for anyone that has already migrated
  however. Anyone who has already migrated their app to AndroidX should
  immediately update to `2.0.0` instead. That's the correctly versioned new push
  of `1.1.0`.

## 1.1.0

* **BAD**. This was a breaking change that was incorrectly published on a minor
  version upgrade, should never have happened. Reverted by 1.1.0+1.

  "**Breaking change**. Migrate from the deprecated original Android Support
  Library to AndroidX. This shouldn't result in any functional changes, but it
  requires any Android apps using this plugin to [also
  migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
  using the original support library."

## 1.0.5

* Bumped Android dependencies to latest.

## 1.0.4

* Bumped test and mockito versions to pick up Dart 2 support.

## 1.0.3

* Bump Android and Firebase dependency versions.

## 1.0.2

* Add `onDisconnect` support.

## 1.0.1

* Updated Gradle tooling to match Android Studio 3.1.2.

## 1.0.0

* Bump to released version

## 0.4.6

* Allow null value for `startAt`, `endAt` and `equalTo` queries on Android.

## 0.4.5

* Updated Google Play Services dependencies to version 15.0.0.

## 0.4.4

* Updated firebase_core dependency to ^0.2.2

## 0.4.3

* Simplified podspec for Cocoapods 1.5.0, avoiding link issues in app archives.

## 0.4.2

* Updated `firebase_core` dependency.
* Removed `meta` dependency.

## 0.4.1

* Fixes Dart 2 runtime cast error.

## 0.4.0

* **Breaking change**. Set SDK constraints to match the Flutter beta release.

## 0.3.6

* Fixed Dart 2 type errors.

## 0.3.5

* Enabled use in Swift projects.

## 0.3.4

* Allow null values for Query startAt, endAt, and equalTo

## 0.3.3

* Support to specify a database by URL if required

## 0.3.2

* Fix warnings from the Dart 2.0 analyzer.
* Simplified and upgraded Android project template to Android SDK 27.
* Updated package description.

## 0.3.1

* Fix function name collision when using Firebase Database and Cloud Firestore together on iOS.

## 0.3.0

* **Breaking change**. Upgraded to Gradle 4.1 and Android Studio Gradle plugin
  3.0.1. Older Flutter projects need to upgrade their Gradle setup as well in
  order to use this version of the plugin. Instructions can be found
  [here](https://github.com/flutter/flutter/wiki/Updating-Flutter-projects-to-Gradle-4.1-and-Android-Studio-Gradle-plugin-3.0.1).

## 0.2.0

* Support for multiple databases, new dependency on firebase_core
* Relax GMS dependency to 11.+

## 0.1.4

* Add FLT prefix to iOS types
* Avoid error when clearing FirebaseSortedList

## 0.1.3

* Fix memory leak in FirebaseAnimatedList
* Change GMS dependency to 11.4.+

## 0.1.2

* Change GMS dependency to 11.+

## 0.1.1

* Add RTDB transaction support.

## 0.1.0+1

* Aligned author name with rest of repo.

## 0.1.0

* **Breaking Change**: Added current list index to the type signature of itemBuilder for FirebaseAnimatedList.

## 0.0.14

* Fix FirebaseSortedList to show data changes.

## 0.0.13

* Fixed lingering value/child listeners.

## 0.0.12

* Updated to Firebase SDK to always use latest patch version for 11.0.x builds

## 0.0.11

* Fixes startAt/endAt on iOS when used without a key

## 0.0.10

* Added workaround for inconsistent numeric types when using keepSynced on iOS
* Bug fixes to Query handling

## 0.0.9

* Updated to Firebase SDK Version 11.0.1

## 0.0.8

* Added missing offline persistence and query functionality on Android
* Fixed startAt query behavior on iOS
* Persistence methods no longer throw errors on failure, return false instead
* Updates to docs and tests

## 0.0.7

* Fixed offline persistence on iOS

## 0.0.6

* Various APIs added to FirebaseDatabase and Query
* Added removal and priority to DatabaseReference
* Improved documentation
* Added unit tests

## 0.0.5

* Fixed analyzer warnings

## 0.0.4

* Removed stub code and replaced it with support for more event types, paths, auth
* Improved example

## 0.0.3

* Updated README.md
* Bumped buildToolsVersion to 25.0.3
* Added example app

## 0.0.2

* Fix compilation error

## 0.0.1

* Initial Release
