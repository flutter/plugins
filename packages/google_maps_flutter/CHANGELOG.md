## 0.5.3

* Added support setting marker icons from bytes.

## 0.5.2

* Added onTap for callback for GoogleMap.

## 0.5.1

* Update Android gradle version.
* Added infrastructure to write integration tests.

## 0.5.0

* Add a key parameter to the GoogleMap widget.

## 0.4.0

* Change events are call backs on GoogleMap widget.
* GoogleMapController no longer handles change events.
* trackCameraPosition is inferred from GoogleMap.onCameraMove being set.

## 0.3.0+3

* Update Android play-services-maps to 16.1.0

## 0.3.0+2

* Address an issue on iOS where icons were not loading.
* Add apache http library required false for Android.

## 0.3.0+1

* Add NSNull Checks for markers controller in iOS.
* Also address an issue where initial markers are set before initialization.

## 0.3.0

* **Breaking change**. Changed the Marker API to be
  widget based, it was controller based. Also changed the
  example app to account for the same.

## 0.2.0+6

* Updated the sample app in README.md.

## 0.2.0+5

* Skip the Gradle Android permissions lint for MyLocation (https://github.com/flutter/flutter/issues/28339)
* Suppress unchecked cast warning for the PlatformViewFactory creation parameters.

## 0.2.0+4

* Fixed a crash when the plugin is registered by a background FlutterView.

## 0.2.0+3

* Fixed a memory leak on Android - the map was not properly disposed.

## 0.2.0+2

* Log a more detailed warning at build time about the previous AndroidX
  migration.

## 0.2.0+1

* Fixed a bug which the camera is not positioned correctly at map initialization(temporary workaround)(https://github.com/flutter/flutter/issues/27550).

## 0.2.0

* **Breaking change**. Migrate from the deprecated original Android Support
  Library to AndroidX. This shouldn't result in any functional changes, but it
  requires any Android apps using this plugin to [also
  migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
  using the original support library.

## 0.1.0

* Move the map options from the GoogleMapOptions class to GoogleMap widget parameters.

## 0.0.3+3

* Relax Flutter version requirement to 0.11.9.

## 0.0.3+2

* Update README to recommend using the package from pub.

## 0.0.3+1

* Bug fix: custom marker images were not working on iOS as we were not keeping
  a reference to the plugin registrar so couldn't fetch assets.

## 0.0.3

* Don't export `dart:async`.
* Update the minimal required Flutter SDK version to one that supports embedding platform views.

## 0.0.2

* Initial developers preview release.
