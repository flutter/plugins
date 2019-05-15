## 3.0.1

* Switch to using the `FIRAnalytics` version of `setAnalyticsCollectionEnabled` for
  compatibility with Firebase Analytics iOS CocoaPod version 6.0.
* Update podspec to ensure availability of `setAnalyticsCollectionEnabled`.

## 3.0.0

* Update Android dependencies to latest.

## 2.1.1+3

* Added an initial integration test.

## 2.1.1+2

* Fixed errors in code sample for `FirebaseAnalyticsObserver`.

## 2.1.1+1

* Added hyperlinks to example app reference in README.md.

## 2.1.1

* Added screen_view tracking of Navigator.pushReplacement

## 2.1.0

* Add Login event support

## 2.0.3

* Add resetAnalyticsData method

## 2.0.2+1

* Log messages about automatic configuration of the default app are now less confusing.

## 2.0.2

* Enable setAnalyticsCollectionEnabled support for iOS

## 2.0.1

* Log a more detailed warning at build time about the previous AndroidX
  migration.

## 2.0.0

* **Breaking change**. Migrate from the deprecated original Android Support
  Library to AndroidX. This shouldn't result in any functional changes, but it
  requires any Android apps using this plugin to [also
  migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
  using the original support library.

  This was originally incorrectly pushed in the `1.2.0` update.

## 1.2.0+1

* **Revert the breaking 1.2.0 update**. 1.2.0 was known to be breaking and
  should have incremented the major version number instead of the minor. This
  revert is in and of itself breaking for anyone that has already migrated
  however. Anyone who has already migrated their app to AndroidX should
  immediately update to `2.0.0` instead. That's the correctly versioned new push
  of `1.2.0`.

## 1.2.0

* **BAD**. This was a breaking change that was incorrectly published on a minor
  version upgrade, should never have happened. Reverted by 1.2.0+1.

  "**Breaking change**. Migrate from the deprecated original Android Support
  Library to AndroidX. This shouldn't result in any functional changes, but it
  requires any Android apps using this plugin to [also
  migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
  using the original support library."

## 1.1.0

* Allow user to handle `PlatformException`s caught by `FirebaseAnalyticsObserver._sendScreenView()`.

## 1.0.6

* Allow user ID to be set to null.

## 1.0.5

* Update the `METHOD` Android constant used for `logSignUp` method.

## 1.0.4

* Bump Android dependencies to latest.

## 1.0.3

* Updated test and mockito dependencies to pick up Dart 2 support

## 1.0.2

* Bump Android and Firebase dependency versions.

## 1.0.1

* Updated Gradle tooling to match Android Studio 3.1.2.

## 1.0.0

* Bump to released version.

## 0.3.3

* Updated Google Play Services dependencies to version 15.0.0.

## 0.3.2

* Updated package channel name

## 0.3.1

* Simplified podspec for Cocoapods 1.5.0, avoiding link issues in app archives.

## 0.3.0

* **Breaking change**. Set SDK constraints to match the Flutter beta release.

## 0.2.3

* Enabled use in Swift projects.

## 0.2.2+1

* Updated description to clarify this is 'Google Analytics for Firebase'

## 0.2.2

* Moved to the io.flutter.plugins organization.

## 0.2.1

* Simplified and upgraded Android project template to Android SDK 27.
* Updated package description.

## 0.2.0

* **Breaking change**. Upgraded to Gradle 4.1 and Android Studio Gradle plugin
  3.0.1. Older Flutter projects need to upgrade their Gradle setup as well in
  order to use this version of the plugin. Instructions can be found
  [here](https://github.com/flutter/flutter/wiki/Updating-Flutter-projects-to-Gradle-4.1-and-Android-Studio-Gradle-plugin-3.0.1).
* Relaxed GMS dependency to [11.4.0,12.0[

## 0.1.2

* Added FLT prefix to iOS types
* Change GMS dependency to 11.4.+

## 0.1.1

* Change GMS dependency to 11.+

## 0.1.0+1

* Aligned author name with rest of repo.

## 0.1.0

* Added `FirebaseAnalyticsObserver` (a `NavigatorObserver`) to automatically log `PageRoute` transitions

## 0.0.5

* Support for long parameter values on Android

## 0.0.4

* Updated to Firebase SDK to always use latest patch version for 11.0.x builds

## 0.0.3

* Updated to Firebase SDK Version 11.0.1

## 0.0.2

* Bumped buildToolsVersion to 25.0.3
* Updated README.md

## 0.0.1

* Initial Release
