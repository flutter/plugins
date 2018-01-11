## 0.1.1

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
