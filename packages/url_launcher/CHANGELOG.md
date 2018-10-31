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
