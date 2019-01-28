## 0.3.0
* **Breaking change**. Migrate from the deprecated original Android Support
  Library to AndroidX. This shouldn't result in any functional changes, but it
  requires any Android apps using this plugin to [also
  migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
  using the original support library.

## 0.2.9+1

* Fix a crash when failing to start preview.

## 0.2.9

* Save photo orientation data on iOS.

## 0.2.8

* Add access to the image stream from Dart.
* Use `cameraController.startImageStream(listener)` to process the images.

## 0.2.7

* Fix issue with crash when the physical device's orientation is unknown.

## 0.2.6

* Update the camera to use the physical device's orientation instead of the UI
  orientation on Android.

## 0.2.5

* Fix preview and video size with satisfying conditions of multiple outputs.

## 0.2.4

* Unregister the activity lifecycle callbacks when disposing the camera.

## 0.2.3

* Added path_provider and video_player as dev dependencies because the example uses them.
* Updated example path_provider version to get Dart 2 support.

## 0.2.2

* iOS image capture is done in high quality (full camera size)

## 0.2.1

* Updated Gradle tooling to match Android Studio 3.1.2.

## 0.2.0

* Added support for video recording.
* Changed the example app to add video recording.

A lot of **breaking changes** in this version:

Getter changes:
 - Removed `isStarted`
 - Renamed `initialized` to `isInitialized`
 - Added `isRecordingVideo`

Method changes:
 - Renamed `capture` to `takePicture`
 - Removed `start` (the preview starts automatically when `initialize` is called)
 - Added `startVideoRecording(String filePath)`
 - Removed `stop` (the preview stops automatically when `dispose` is called)
 - Added `stopVideoRecording`

## 0.1.2

* Fix Dart 2 runtime errors.

## 0.1.1

* Fix Dart 2 runtime error.

## 0.1.0

* **Breaking change**. Set SDK constraints to match the Flutter beta release.

## 0.0.4

* Revert regression of `CameraController.capture()` introduced in v. 0.0.3.

## 0.0.3

* Improved resource cleanup on Android. Avoids crash on Activity restart.
* Made the Future returned by `CameraController.dispose()` and `CameraController.capture()` actually complete on
  Android.

## 0.0.2

* Simplified and upgraded Android project template to Android SDK 27.
* Moved Android package to io.flutter.plugins.
* Fixed warnings from the Dart 2.0 analyzer.

## 0.0.1

* Initial release
