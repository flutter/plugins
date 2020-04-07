## 0.10.8+2

* Replace deprecated `getFlutterEngine` call on Android.

## 0.10.8+1

* Make the pedantic dev_dependency explicit.

## 0.10.8

* Added support for cleaning up the plugin if used for add-to-app (Flutter
  v1.15.3 is required for that feature).


## 0.10.7

* `VideoPlayerController` support for reading closed caption files. 
* `VideoPlayerValue` has a `caption` field for reading the current closed caption at any given time.

## 0.10.6

* `ClosedCaptionFile` and `SubRipCaptionFile` classes added to read
  [SubRip](https://en.wikipedia.org/wiki/SubRip) files into dart objects.

## 0.10.5+3

* Add integration instructions for the `web` platform.

## 0.10.5+2

* Make sure the plugin is correctly initialized

## 0.10.5+1

* Fixes issue where `initialize()` `Future` stalls when failing to load source
  data and does not throw an error.

## 0.10.5

* Support `web` by default.
* Require Flutter SDK 1.12.13+hotfix.4 or greater.

## 0.10.4+2

* Remove the deprecated `author:` field form pubspec.yaml
* Migrate the plugin to the pubspec platforms manifest.
* Require Flutter SDK 1.10.0 or greater.

## 0.10.4+1

* Fix pedantic lints. This fixes some potential race conditions in cases where
  futures within some video_player methods weren't being awaited correctly.

## 0.10.4

* Port plugin code to use the federated Platform Interface, instead of a MethodChannel directly.

## 0.10.3+3

* Add DartDocs and unit tests.

## 0.10.3+2

* Update the homepage to point to the new plugin location

## 0.10.3+1

* Dispose `FLTVideoPlayer` in `onTextureUnregistered` callback on iOS.
* Add a temporary fix to dispose the `FLTVideoPlayer` with a delay to avoid race condition.
* Updated the example app to include a new page that pop back after video is done playing.

## 0.10.3

* Add support for the v2 Android embedding. This shouldn't impact existing
  functionality.

## 0.10.2+6

* Remove AndroidX warnings.

## 0.10.2+5

* Update unit test for compatibility with Flutter stable branch.

## 0.10.2+4

* Define clang module for iOS.

## 0.10.2+3

* Fix bug where formatHint was not being pass down to network sources.

## 0.10.2+2

* Update and migrate iOS example project.

## 0.10.2+1

* Use DefaultHttpDataSourceFactory only when network schemas and use
DefaultHttpDataSourceFactory by default.

## 0.10.2

* **Android Only** Adds optional VideoFormat used to signal what format the plugin should try.

## 0.10.1+7

* Fix tests by ignoring deprecated member use.

## 0.10.1+6

* [iOS] Fixed a memory leak with notification observing.

## 0.10.1+5

* Fix race condition while disposing the VideoController.

## 0.10.1+4

* Fixed syntax error in README.md.

## 0.10.1+3

* Add missing template type parameter to `invokeMethod` calls.
* Bump minimum Flutter version to 1.5.0.
* Replace invokeMethod with invokeMapMethod wherever necessary.

## 0.10.1+2

* Example: Fixed tab display and added scroll view

## 0.10.1+1

* iOS: Avoid deprecated `seekToTime` API

## 0.10.1

* iOS: Consider a player only `initialized` once duration is determined.

## 0.10.0+8

* iOS: Fix an issue where the player sends initialization message incorrectly.

* Fix a few other IDE warnings.


## 0.10.0+7

* Android: Fix issue where buffering status in percentage instead of milliseconds

* Android: Update buffering status everytime we notify for position change

## 0.10.0+6

* Android: Fix missing call to `event.put("event", "completed");` which makes it possible to detect when the video is over.

## 0.10.0+5

* Fixed iOS build warnings about implicit retains.

## 0.10.0+4

* Android: Upgrade ExoPlayer to 2.9.6.

## 0.10.0+3

* Fix divide by zero bug on iOS.

## 0.10.0+2

* Added supported format documentation in README.

## 0.10.0+1

* Log a more detailed warning at build time about the previous AndroidX
  migration.

## 0.10.0

* **Breaking change**. Migrate from the deprecated original Android Support
  Library to AndroidX. This shouldn't result in any functional changes, but it
  requires any Android apps using this plugin to [also
  migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
  using the original support library.

## 0.9.0

* Fixed the aspect ratio and orientation of videos. Videos are now properly displayed when recorded
 in portrait mode both in iOS and Android.

## 0.8.0

* Android: Upgrade ExoPlayer to 2.9.1
* Android: Use current gradle dependencies
* Android 9 compatibility fixes for Demo App

## 0.7.2

* Updated to use factories on exoplayer `MediaSource`s for Android instead of the now-deprecated constructors.

## 0.7.1

* Fixed null exception on Android when the video has a width or height of 0.

## 0.7.0

* Add a unit test for controller and texture changes. This is a breaking change since the interface
  had to be cleaned up to facilitate faking.

## 0.6.6

* Fix the condition where the player doesn't update when attached controller is changed.

## 0.6.5

* Eliminate race conditions around initialization: now initialization events are queued and guaranteed
  to be delivered to the Dart side. VideoPlayer widget is rebuilt upon completion of initialization.

## 0.6.4

* Android: add support for hls, dash and ss video formats.

## 0.6.3

* iOS: Allow audio playback in silent mode.

## 0.6.2

* `VideoPlayerController.seekTo()` is now frame accurate on both platforms.

## 0.6.1

* iOS: add missing observer removals to prevent crashes on deallocation.

## 0.6.0

* Android: use ExoPlayer instead of MediaPlayer for better video format support.

## 0.5.5

* **Breaking change** `VideoPlayerController.initialize()` now only completes after the controller is initialized.
* Updated example in README.md.

## 0.5.4

* Updated Gradle tooling to match Android Studio 3.1.2.

## 0.5.3

* Added video buffering status.

## 0.5.2

* Fixed a bug on iOS that could lead to missing initialization.
* Added support for HLS video on iOS.

## 0.5.1

* Fixed bug on video loop feature for iOS.

## 0.5.0

* Added the constructor `VideoPlayerController.file`.
* **Breaking change**. Changed `VideoPlayerController.isNetwork` to
  an enum `VideoPlayerController.dataSourceType`.

## 0.4.1

* Updated Flutter SDK constraint to reflect the changes in v0.4.0.

## 0.4.0

* **Breaking change**. Removed the `VideoPlayerController` constructor
* Added two new factory constructors `VideoPlayerController.asset` and
  `VideoPlayerController.network` to respectively play a video from the
  Flutter assets and from a network uri.

## 0.3.0

* **Breaking change**. Set SDK constraints to match the Flutter beta release.

## 0.2.1

* Fixed some signatures to account for strong mode runtime errors.
* Fixed spelling mistake in toString output.

## 0.2.0

* **Breaking change**. Renamed `VideoPlayerController.isErroneous` to `VideoPlayerController.hasError`.
* Updated documentation of when fields are available on `VideoPlayerController`.
* Updated links in README.md.

## 0.1.1

* Simplified and upgraded Android project template to Android SDK 27.
* Moved Android package to io.flutter.plugins.
* Fixed warnings from the Dart 2.0 analyzer.

## 0.1.0

* **Breaking change**. Upgraded to Gradle 4.1 and Android Studio Gradle plugin
  3.0.1. Older Flutter projects need to upgrade their Gradle setup as well in
  order to use this version of the plugin. Instructions can be found
  [here](https://github.com/flutter/flutter/wiki/Updating-Flutter-projects-to-Gradle-4.1-and-Android-Studio-Gradle-plugin-3.0.1).

## 0.0.7

* Added access to the video size.
* Made the VideoProgressIndicator render using a LinearProgressIndicator.

## 0.0.6

* Fixed a bug related to hot restart on Android.

## 0.0.5

* Added VideoPlayerValue.toString().
* Added FLT prefix to iOS types.

## 0.0.4

* The player will now pause on app pause, and resume on app resume.
* Implemented scrubbing on the progress bar.

## 0.0.3

* Made creating a VideoPlayerController a synchronous operation. Must be followed by a call to initialize().
* Added VideoPlayerController.setVolume().
* Moved the package to flutter/plugins github repo.

## 0.0.2

* Fix meta dependency version.

## 0.0.1

* Initial release
