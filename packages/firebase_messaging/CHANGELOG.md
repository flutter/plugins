## 3.0.1

* Log a more detailed warning at build time about the previous AndroidX
  migration.

## 3.0.0

* **Breaking change**. Migrate from the deprecated original Android Support
  Library to AndroidX. This shouldn't result in any functional changes, but it
  requires any Android apps using this plugin to [also
  migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
  using the original support library.

  This was originally incorrectly pushed in the `2.2.0` update.

## 2.2.0+1

* **Revert the breaking 2.2.0 update**. 2.2.0 was known to be breaking and
  should have incremented the major version number instead of the minor. This
  revert is in and of itself breaking for anyone that has already migrated
  however. Anyone who has already migrated their app to AndroidX should
  immediately update to `3.0.0` instead. That's the correctly versioned new push
  of `2.2.0`.

## 2.2.0

* **BAD**. This was a breaking change that was incorrectly published on a minor
  version upgrade, should never have happened. Reverted by `2.2.0+1`.

* **Breaking change**. Migrate from the deprecated original Android Support
  Library to AndroidX. This shouldn't result in any functional changes, but it
  requires any Android apps using this plugin to [also
  migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
  using the original support library.

## 2.1.0

* Adding support for deleteInstanceID(), autoInitEnabled() and setAutoInitEnabled().

## 2.0.3

* Removing local cache of getToken() in the dart part of the plugin. Now getToken() calls directly its counterparts in the iOS and Android implementations. This enables obtaining its value without calling configure() or having to wait for a new token refresh.

## 2.0.2

* Use boolean values when checking for notification types on iOS.

## 2.0.1

* Bump Android dependencies to latest.

## 2.0.0

* Updated Android to send Remote Message's title and body to Dart.

## 1.0.5

* Bumped test and mockito versions to pick up Dart 2 support.

## 1.0.4

* Bump Android and Firebase dependency versions.

## 1.0.3

* Updated iOS token hook from 'didRefreshRegistrationToken' to 'didReceiveRegistrationToken'

## 1.0.2

* Updated Gradle tooling to match Android Studio 3.2.2.

## 1.0.1

* Fix for Android where the onLaunch event is not triggered when the Activity is killed by the OS (or if the Don't keep activities toggle is enabled)

## 1.0.0

* Bump to released version

## 0.2.5

* Fixed Dart 2 type error.

## 0.2.4

* Updated Google Play Services dependencies to version 15.0.0.

## 0.2.3

* Updated package channel name

## 0.2.2

* Simplified podspec for Cocoapods 1.5.0, avoiding link issues in app archives.

## 0.2.1

* Fixed Dart 2 type errors.

## 0.2.0

* **Breaking change**. Set SDK constraints to match the Flutter beta release.

## 0.1.4

* Fixed Dart 2 type error in example project.

## 0.1.3

* Enabled use in Swift projects.

## 0.2.2

* Fix for APNS not being correctly registered on iOS when reinstalling application.

## 0.1.1

* Simplified and upgraded Android project template to Android SDK 27.
* Updated package description.

## 0.1.0

* **Breaking change**. Upgraded to Gradle 4.1 and Android Studio Gradle plugin
  3.0.1. Older Flutter projects need to upgrade their Gradle setup as well in
  order to use this version of the plugin. Instructions can be found
  [here](https://github.com/flutter/flutter/wiki/Updating-Flutter-projects-to-Gradle-4.1-and-Android-Studio-Gradle-plugin-3.0.1).
* Relaxed GMS dependency to [11.4.0,12.0[

## 0.0.8

* Added FLT prefix to iOS types
* Change GMS dependency to 11.4.+

## 0.0.7

In FirebaseMessagingPlugin.m:
* moved logic from 'tokenRefreshNotification' to 'didRefreshRegistrationToken'
* removed 'tokenRefreshNotification' as well as observer registration
* removed 'connectToFcm' method and related calls
* removed unnecessary FIRMessaging disconnect

## 0.0.6

* Change GMS dependency to 11.+

## 0.0.5+2

* Fixed README example for "click_action"

## 0.0.5+1

* Aligned author name with rest of repo.

## 0.0.5

* Updated to Firebase SDK to always use latest patch version for 11.0.x builds

## 0.0.4

* Updated to Firebase SDK Version 11.0.1

## 0.0.3

* Updated README.md
* Bumped buildToolsVersion to 25.0.3

## 0.0.2+2

* Updated README.md

## 0.0.2+1

* Added workaround for https://github.com/flutter/flutter/issues/9694 to README
* Moved code to https://github.com/flutter/plugins

## 0.0.2

* Updated to latest plugin API

## 0.0.2.2

* Downgraded gradle dependency for example app to make `flutter run` happy

## 0.0.1+1

* Updated README with installation instructions
* Added CHANGELOG

## 0.0.1

* Initial Release
