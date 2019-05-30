## 0.5.15

* Add support for Polygons.

## 0.5.14+1

* Example app update(comment out usage of the ImageStreamListener API which has a breaking change
  that's not yet on master). See: https://github.com/flutter/flutter/issues/33438

## 0.5.14

* Adds onLongPress callback for GoogleMap.

## 0.5.13

* Add support for Circle overlays.

## 0.5.12

* Prevent calling null callbacks and callbacks on removed objects.

## 0.5.11+1

* Android: Fix an issue where myLocationButtonEnabled setting was not propagated when set to false onMapLoad.

## 0.5.11

* Add myLocationButtonEnabled option.

## 0.5.10

* Support Color's alpha channel when converting to UIColor on iOS.

## 0.5.9

* BitmapDescriptor#fromBytes accounts for screen scale on ios.

## 0.5.8

* Remove some unused variables and rename method

## 0.5.7

* Add a BitmapDescriptor that is aware of scale.

## 0.5.6

* Add support for Polylines on GoogleMap.

## 0.5.5

* Enable iOS accessibility.

## 0.5.4

* Add method getVisibleRegion for get the latlng bounds of the visible map area.

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
