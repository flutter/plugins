## 0.6.4

* Add a new parameter to select preferred camera device.

## 0.6.3+4

* Make the pedantic dev_dependency explicit.

## 0.6.3+3

* Android: Fix a crash when `externalFilesDirectory` does not exist.

## 0.6.3+2

* Bump RoboElectric dependency to 4.3.1 and update resource usage.

## 0.6.3+1

* Fix an issue that the example app won't launch the image picker after Android V2 embedding migration.

## 0.6.3

* Support Android V2 embedding.
* Migrate to using the new e2e test binding.

## 0.6.2+3

* Remove the deprecated `author:` field from pubspec.yaml
* Migrate the plugin to the pubspec platforms manifest.
* Require Flutter SDK 1.10.0 or greater.

## 0.6.2+2

* Android: Revert the image file return logic when the image doesn't have to be scaled. Fix a rotation regression caused by 0.6.2+1
* Example App: Add a dialog to enter `maxWidth`, `maxHeight` or `quality` when picking image.

## 0.6.2+1

* Android: Fix a crash when a non-image file is picked.
* Android: Fix unwanted bitmap scaling.

## 0.6.2

* iOS: Fixes an issue where picking content from Gallery would result in a crash on iOS 13.

## 0.6.1+11

* Stability and Maintainability: update documentations, add unit tests.

## 0.6.1+10

* iOS: Fix image orientation problems when scaling images.

## 0.6.1+9

* Remove AndroidX warning.

## 0.6.1+8

* Fix iOS build and analyzer warnings.

## 0.6.1+7

* Android: Fix ImagePickerPlugin#onCreate casting context which causes exception.

## 0.6.1+6

* Define clang module for iOS

## 0.6.1+5

* Update and migrate iOS example project.

## 0.6.1+4

* Android: Fix a regression where the `retrieveLostImage` does not work anymore.
* Set up Android unit test to test `ImagePickerCache` and added image quality caching tests.

## 0.6.1+3

* Bugfix iOS: Fix orientation of the picked image after scaling.
* Remove unnecessary code that tried to normalize the orientation.
* Trivial XCTest code fix.

## 0.6.1+2

* Replace dependency on `androidx.legacy:legacy-support-v4:1.0.0` with `androidx.core:core:1.0.2`

## 0.6.1+1

* Add dependency on `androidx.annotation:annotation:1.0.0`.

## 0.6.1

* New feature : Get images with custom quality. While picking images, user can pass `imageQuality`
parameter to compress image.

## 0.6.0+20

* Android: Migrated information cache methods to use instance methods.

## 0.6.0+19

* Android: Fix memory leak due not unregistering ActivityLifecycleCallbacks.

## 0.6.0+18

* Fix video play in example and update video_player plugin dependency.

## 0.6.0+17

* iOS: Fix a crash when user captures image from the camera with devices under iOS 11.

## 0.6.0+16

* iOS Simulator: fix hang after trying to take an image from the non-existent camera.

## 0.6.0+15

* Android: throws an exception when permissions denied instead of ignoring.

## 0.6.0+14

* Fix typo in README.

## 0.6.0+13

* Bugfix Android: Fix a crash occurs in some scenarios when user picks up image from gallery.

## 0.6.0+12

* Use class instead of struct for `GIFInfo` in iOS implementation.

## 0.6.0+11

* Don't use module imports.

## 0.6.0+10

* iOS: support picking GIF from gallery.

## 0.6.0+9

* Add missing template type parameter to `invokeMethod` calls.
* Bump minimum Flutter version to 1.5.0.
* Replace invokeMethod with invokeMapMethod wherever necessary.

## 0.6.0+8

* Bugfix: Add missed return statement into the image_picker example.

## 0.6.0+7

* iOS: Rename objects to follow Objective-C naming convention to avoid conflicts with other iOS library/frameworks.

## 0.6.0+6

* iOS: Picked image now has all the correct meta data from the original image, includes GPS, orientation and etc.

## 0.6.0+5

* iOS: Add missing import.

## 0.6.0+4

* iOS: Using first byte to determine original image type.
* iOS: Added XCTest target.
* iOS: The picked image now has the correct EXIF data copied from the original image.

## 0.6.0+3

* Android: fixed assertion failures due to reply messages that were sent on the wrong thread.

## 0.6.0+2

* Android: images are saved with their real extension instead of always using `.jpg`.

## 0.6.0+1

* Android: Using correct suffix syntax when picking image from remote url.

## 0.6.0

* Breaking change iOS: Returned `File` objects when picking videos now always holds the correct path. Before this change, the path returned could have `file://` prepended to it.

## 0.5.4+3

* Fix the example app failing to load picked video.

## 0.5.4+2

* Request Camera permission if it present in Manifest on Android >= M.

## 0.5.4+1

* Bugfix iOS: Cancel button not visible in gallery, if camera was accessed first.

## 0.5.4

* Add `retrieveLostData` to retrieve lost data after MainActivity is killed.

## 0.5.3+2

* Android: fix a crash when the MainActivity is destroyed after selecting the image/video.

## 0.5.3+1

* Update minimum deploy iOS version to 8.0.

## 0.5.3

* Fixed incorrect path being returned from Google Photos on Android.

## 0.5.2

* Check iOS camera authorizationStatus and return an error, if the access was
  denied.

## 0.5.1

* Android: Do not delete original image after scaling if the image is from gallery.

## 0.5.0+9

* Remove unnecessary temp video file path.

## 0.5.0+8

* Fixed wrong GooglePhotos authority of image Uri.

## 0.5.0+7

* Fix a crash when selecting images from yandex.disk and dropbox.

## 0.5.0+6

* Delete the original image if it was scaled.

## 0.5.0+5

* Remove unnecessary camera permission.

## 0.5.0+4

* Preserve transparency when saving images.

## 0.5.0+3

* Fixed an Android crash when Image Picker is registered without an activity.

## 0.5.0+2

* Log a more detailed warning at build time about the previous AndroidX
  migration.

## 0.5.0+1

* Fix a crash when user calls the plugin in quick succession on Android.

## 0.5.0

* **Breaking change**. Migrate from the deprecated original Android Support
  Library to AndroidX. This shouldn't result in any functional changes, but it
  requires any Android apps using this plugin to [also
  migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
  using the original support library.

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
