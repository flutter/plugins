## 0.5.8+5

* Fix compilation/availability issues on iOS.

## 0.5.8+4

* Fixed bug caused by casting a `CameraAccessException` on Android.

## 0.5.8+3

* Fix bug in usage example in README.md

## 0.5.8+2

* Post-v2 embedding cleanups.

## 0.5.8+1

* Update lower bound of dart dependency to 2.1.0.

## 0.5.8

* Remove Android dependencies fallback.
* Require Flutter SDK 1.12.13+hotfix.5 or greater.

## 0.5.7+5

* Replace deprecated `getFlutterEngine` call on Android.

## 0.5.7+4

* Add `pedantic` to dev_dependency.

## 0.5.7+3

* Fix an Android crash when permissions are requested multiple times.

## 0.5.7+2

* Remove the deprecated `author:` field from pubspec.yaml
* Migrate the plugin to the pubspec platforms manifest.
* Require Flutter SDK 1.10.0 or greater.

## 0.5.7+1

* Fix example null exception.

## 0.5.7

* Fix unawaited futures.

## 0.5.6+4

* Android: Use CameraDevice.TEMPLATE_RECORD to improve image streaming.

## 0.5.6+3

* Remove AndroidX warning.

## 0.5.6+2

* Include lifecycle dependency as a compileOnly one on Android to resolve
  potential version conflicts with other transitive libraries.

## 0.5.6+1

* Android: Use android.arch.lifecycle instead of androidx.lifecycle:lifecycle in `build.gradle` to support apps that has not been migrated to AndroidX.

## 0.5.6

* Add support for the v2 Android embedding. This shouldn't affect existing
  functionality.

## 0.5.5+1

* Fix event type check

## 0.5.5

* Define clang modules for iOS.

## 0.5.4+3

* Update and migrate iOS example project.

## 0.5.4+2

* Fix Android NullPointerException on devices with only front-facing camera.

## 0.5.4+1

* Fix Android pause and resume video crash when executing in APIs below 24.

## 0.5.4

* Add feature to pause and resume video recording.

## 0.5.3+1

* Fix too large request code for FragmentActivity users.

## 0.5.3

* Added new quality presets.
* Now all quality presets can be used to control image capture quality.

## 0.5.2+2

* Fix memory leak related to not unregistering stream handler in FlutterEventChannel when disposing camera.

## 0.5.2+1

* Fix bug that prevented video recording with audio.

## 0.5.2

* Added capability to disable audio for the `CameraController`. (e.g. `CameraController(_, _,
 enableAudio: false);`)

## 0.5.1

* Can now be compiled with earlier Android sdks below 21 when
`<uses-sdk tools:overrideLibrary="io.flutter.plugins.camera"/>` has been added to the project
`AndroidManifest.xml`. For sdks below 21, the plugin won't be registered and calls to it will throw
a `MissingPluginException.`

## 0.5.0

* **Breaking Change** This plugin no longer handles closing and opening the camera on Android
  lifecycle changes. Please use `WidgetsBindingObserver` to control camera resources on lifecycle
  changes. See example project for example using `WidgetsBindingObserver`.

## 0.4.3+2

* Bump the minimum Flutter version to 1.2.0.
* Add template type parameter to `invokeMethod` calls.

## 0.4.3+1

* Catch additional `Exception`s from Android and throw as `CameraException`s.

## 0.4.3

* Add capability to prepare the capture session for video recording on iOS.

## 0.4.2

* Add sensor orientation value to `CameraDescription`.

## 0.4.1

* Camera methods are ran in a background thread on iOS.

## 0.4.0+3

* Fixed a crash when the plugin is registered by a background FlutterView.

## 0.4.0+2

* Fix orientation of captured photos when camera is used for the first time on Android.

## 0.4.0+1

* Remove categories.

## 0.4.0

* **Breaking Change** Change iOS image stream format to `ImageFormatGroup.bgra8888` from
  `ImageFormatGroup.yuv420`.

## 0.3.0+4

* Fixed bug causing black screen on some Android devices.

## 0.3.0+3

* Log a more detailed warning at build time about the previous AndroidX
  migration.

## 0.3.0+2

* Fix issue with calculating iOS image orientation in certain edge cases.

## 0.3.0+1

* Remove initial method call invocation from static camera method.

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
