## 5.4.4

* Replace deprecated `getFlutterEngine` call on Android.

## 5.4.3

* Fixed the launchUniversalLinkIos method.

## 5.4.2

* Make the pedantic dev_dependency explicit.

## 5.4.1

* Update unit tests to work with the PlatformInterface from package `plugin_platform_interface`.

## 5.4.0

* Support macos by default.

## 5.3.0

* Support web by default.
* Use the new plugins pubspec schema.

## 5.2.7

* Minor unit test changes and added a lint for public DartDocs.

## 5.2.6

*  Remove AndroidX warnings.

## 5.2.5

* Include lifecycle dependency as a compileOnly one on Android to resolve
  potential version conflicts with other transitive libraries.

## 5.2.4

* Use `package:url_launcher_platform_interface` to get the platform-specific implementation.

## 5.2.3

Android: Use android.arch.lifecycle instead of androidx.lifecycle:lifecycle in `build.gradle` to support apps that has not been migrated to AndroidX.

## 5.2.2

* Re-land embedder v2 support with correct Flutter SDK constraints.

## 5.2.1

* Revert the migration since the Flutter dependency was too low.

## 5.2.0

* Migrate the plugin to use the V2 Android engine embedding. This shouldn't
  affect existing functionality. Plugin authors who use the V2 embedding can now
  instantiate the plugin and expect that it correctly responds to app lifecycle
  changes.

## 5.1.7

* Define clang module for iOS.

## 5.1.6

* Fixes bug where androidx app won't build with this plugin by enabling androidx and jetifier in the android `gradle.properties`.

## 5.1.5

* Update homepage url after moving to federated directory.

## 5.1.4

* Update and migrate iOS example project.

## 5.1.3

* Always launch url from the top most UIViewController in iOS.

## 5.1.2

* Update AGP and gradle.
* Split plugin and WebViewActivity class files.

## 5.1.1

* Suppress a handled deprecation warning on iOS

## 5.1.0

* Add `headers` field to enable headers in the Android implementation.

## 5.0.5

* Add `enableDomStorage` field to `launch` to enable DOM storage in Android WebView.

## 5.0.4

* Update Dart code to conform to current Dart formatter.

## 5.0.3

* Add missing template type parameter to `invokeMethod` calls.
* Bump minimum Flutter version to 1.5.0.
* Replace invokeMethod with invokeMapMethod wherever necessary.

## 5.0.2

* Fixes `closeWebView` failure on iOS.

## 5.0.1

* Log a more detailed warning at build time about the previous AndroidX
  migration.

## 5.0.0

* **Breaking change**. Migrate from the deprecated original Android Support
  Library to AndroidX. This shouldn't result in any functional changes, but it
  requires any Android apps using this plugin to [also
  migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
  using the original support library.

  This was originally incorrectly pushed in the `4.2.0` update.

## 4.2.0+3

* **Revert the breaking 4.2.0 update**. 4.2.0 was known to be breaking and
  should have incremented the major version number instead of the minor. This
  revert is in and of itself breaking for anyone that has already migrated
  however. Anyone who has already migrated their app to AndroidX should
  immediately update to `5.0.0` instead. That's the correctly versioned new push
  of `4.2.0`.

## 4.2.0+2

* Updated `launch` to use async and await, fixed the incorrect return value by `launch` method.

## 4.2.0+1

* Refactored the Java and Objective-C code. Replaced instance variables with properties in Objective-C.

## 4.2.0

* **BAD**. This was a breaking change that was incorrectly published on a minor
  version upgrade, should never have happened. Reverted by 4.2.0+3.

* **Breaking change**. Migrate from the deprecated original Android Support
  Library to AndroidX. This shouldn't result in any functional changes, but it
  requires any Android apps using this plugin to [also
  migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
  using the original support library.

## 4.1.0+1

* This is just a version bump to republish as 4.1.0 was published with some dirty local state.

## 4.1.0

* Added `universalLinksOnly` setting.
* Updated `launch` to return `Future<bool>`.

## 4.0.3

* Fixed launch url fail for Android: `launch` now assert activity not null and using activity to startActivity.
* Fixed `WebViewActivity has leaked IntentReceiver` for Android.

## 4.0.2

* Added `closeWebView` function to programmatically close the current WebView.

## 4.0.1

* Added enableJavaScript field to `launch` to enable javascript in Android WebView.

## 4.0.0

* **Breaking change** Now requires a minimum Flutter version of 0.5.6.
* Update to statusBarBrightness field so that the logic runs on the Flutter side.
* **Breaking change** statusBarBrightness no longer has a default value.

## 3.0.3

* Added statusBarBrightness field to `launch` to set iOS status bar brightness.

## 3.0.2

* Updated Gradle tooling to match Android Studio 3.1.2.

## 3.0.1

* Fix a crash during Safari view controller dismiss.

## 3.0.0

* **Breaking change**. Set SDK constraints to match the Flutter beta release.

## 2.0.2

* Fixed Dart 2 issue: `launch` now returns `Future<void>` instead of
  `Future<Null>`.

## 2.0.1

* Simplified and upgraded Android project template to Android SDK 27.
* Updated package description.

## 2.0.0

* **Breaking change**. Upgraded to Gradle 4.1 and Android Studio Gradle plugin
  3.0.1. Older Flutter projects need to upgrade their Gradle setup as well in
  order to use this version of the plugin. Instructions can be found
  [here](https://github.com/flutter/flutter/wiki/Updating-Flutter-projects-to-Gradle-4.1-and-Android-Studio-Gradle-plugin-3.0.1).

## 1.0.3

* Add FLT prefix to iOS types.

## 1.0.2

* Fix handling of URLs in Android WebView.

## 1.0.1

* Support option to launch default browser in iOS.
* Parse incoming url and decide on what to open based on scheme.
* Support WebView on Android.

## 1.0.0

* iOS plugin presents a Safari view controller instead of switching to the Safari app.

## 0.4.2+5

* Aligned author name with rest of repo.

## 0.4.2+2, 0.4.2+3, 0.4.2+4

* Updated README.

## 0.4.2+1

* Updated README.

## 0.4.2

* Change to README.md.

## 0.4.1

* Upgrade Android SDK Build Tools to 25.0.3.

## 0.4.0

* Upgrade to new plugin registration.

## 0.3.6

* Fix workaround for failing dynamic check in Xcode 7/sdk version 9.

## 0.3.5

* Workaround for failing dynamic check in Xcode 7/sdk version 9.

## 0.3.4

* Add test.

## 0.3.3

* Change to buildToolsVersion.

## 0.3.2

* Change to README.md.

## 0.3.1

* Change to README.md.

## 0.3.0

* Add `canLaunch` method.

## 0.2.0

* Change `launch` to a top-level method instead of a static method in a class.

## 0.1.1

* Change to README.md.

## 0.1.0

* Initial Open Source release.
