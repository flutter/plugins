## 0.4.12+1

* Fix a crash when selecting downloaded images from image picker on certain devices.

## 0.4.12

* Fix a crash when user tap the image mutiple times.

## 0.4.11

* Use `api` to define `support-v4` dependency to allow automatic version resolution.

## 0.4.10

* Depend on full `support-v4` library for ease of use (fixes conflicts with Firebase and libraries)

## 0.4.9

* Bugfix: on iOS prevent to appear one pixel white line on resized image.

## 0.4.8

* Replace the full `com.android.support:appcompat-v7` dependency with `com.android.support:support-core-utils`, which results in smaller APK sizes.
* Upgrade support library to 27.1.1

## 0.4.7

* Added missing video_player package dev dependency.

## 0.4.6

* Added support for picking remote images.

## 0.4.5

* Bugfixes, code cleanup, more test coverage.

## 0.4.4

* Updated Gradle tooling to match Android Studio 3.1.2.

## 0.4.3

* Bugfix: on iOS the `pickVideo` method will now return null when the user cancels picking a video.

## 0.4.2

* Added support for picking videos.
* Updated example app to show video preview.

## 0.4.1

* Bugfix: the `pickImage` method will now return null when the user cancels picking the image, instead of hanging indefinitely.
* Removed the third party library dependency for taking pictures with the camera.

## 0.4.0

* **Breaking change**. The `source` parameter for the `pickImage` is now required. Also, the `ImageSource.any` option doesn't exist anymore.
* Use the native Android image gallery for picking images instead of a custom UI.

## 0.3.1

* Bugfix: Android version correctly asks for runtime camera permission when using `ImageSource.camera`.

## 0.3.0

* **Breaking change**. Set SDK constraints to match the Flutter beta release.

## 0.2.1

* Simplified and upgraded Android project template to Android SDK 27.
* Updated package description.

## 0.2.0

* **Breaking change**. Upgraded to Gradle 4.1 and Android Studio Gradle plugin
  3.0.1. Older Flutter projects need to upgrade their Gradle setup as well in
  order to use this version of the plugin. Instructions can be found
  [here](https://github.com/flutter/flutter/wiki/Updating-Flutter-projects-to-Gradle-4.1-and-Android-Studio-Gradle-plugin-3.0.1).

## 0.1.5

* Added FLT prefix to iOS types

## 0.1.4

* Bugfix: canceling image picking threw exception.
* Bugfix: errors in plugin state management.

## 0.1.3

* Added optional source argument to pickImage for controlling where the image comes from.

## 0.1.2

* Added optional maxWidth and maxHeight arguments to pickImage.

## 0.1.1

* Updated Gradle repositories declaration to avoid the need for manual configuration
  in the consuming app.

## 0.1.0+1

* Updated readme and description in pubspec.yaml

## 0.1.0

* Updated dependencies
* **Breaking Change**: You need to add a maven section with the "https://maven.google.com" endpoint to the repository section of your `android/build.gradle`. For example:
```gradle
allprojects {
    repositories {
        jcenter()
        maven {                              // NEW
            url "https://maven.google.com"   // NEW
        }                                    // NEW
    }
}
```

## 0.0.3

* Fix for crash on iPad when showing the Camera/Gallery selection dialog

## 0.0.2+2

* Updated README

## 0.0.2+1

* Updated README

## 0.0.2

* Fix crash when trying to access camera on a device without camera (e.g. the Simulator)

## 0.0.1

* Initial Release
