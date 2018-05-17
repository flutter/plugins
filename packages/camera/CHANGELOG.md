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
