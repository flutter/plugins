## 0.5.25

* Add an optional param `mipmaps` for `BitmapDescriptor.fromAssetImage`.

## 0.5.24+1

* Make the pedantic dev_dependency explicit.

## 0.5.24

* Exposed `getZoomLevel` in `GoogleMapController`.

## 0.5.23+1

* Move core plugin to its own subdirectory, to prepare for federation.

## 0.5.23

* Add methods to programmatically control markers info windows.

## 0.5.22+3

* Fix polygon and circle stroke width according to device density

## 0.5.22+2

* Update README: Add steps to enable Google Map SDK in the Google Developer Console.

## 0.5.22+1

* Fix for toggling traffic layer on Android not working

## 0.5.22

* Support Android v2 embedding.
* Bump the min flutter version to `1.12.13+hotfix.5`.
* Fixes some e2e tests on Android.

## 0.5.21+17

* Fix Swift example in README.md.

## 0.5.21+16

* Fixed typo in LatLng's documentation.

## 0.5.21+15

* Remove the deprecated `author:` field from pubspec.yaml
* Migrate the plugin to the pubspec platforms manifest.
* Require Flutter SDK 1.10.0 or greater.

## 0.5.21+14

* Adds support for toggling 3D buildings.

## 0.5.21+13

* Add documentation.

## 0.5.21+12

* Update driver tests in the example app to e2e tests.

## 0.5.21+11

* Define clang module for iOS, fix analyzer warnings.

## 0.5.21+10

* Cast error.code to unsigned long to avoid using NSInteger as %ld format warnings.

## 0.5.21+9

* Remove AndroidX warnings.

## 0.5.21+8

* Add NS_ASSUME_NONNULL_* macro to reduce iOS compiler warnings.

## 0.5.21+7

* Create a clone of cached elements in GoogleMap (Polyline, Polygon, etc.) to detect modifications
  if these objects are mutated instead of modified by copy.

## 0.5.21+6

* Override a default method to work around flutter/flutter#40126.

## 0.5.21+5

* Update and migrate iOS example project.

## 0.5.21+4

* Support projection methods to translate between screen and latlng coordinates.

## 0.5.21+3

* Fix `myLocationButton` bug in `google_maps_flutter` iOS.

## 0.5.21+2

* Fix more `prefer_const_constructors` analyzer warnings in example app.

## 0.5.21+1

* Fix `prefer_const_constructors` analyzer warnings in example app.

## 0.5.21

* Don't recreate map elements if they didn't change since last widget build.

## 0.5.20+6

* Adds support for toggling the traffic layer

## 0.5.20+5

* Allow (de-)serialization of CameraPosition

## 0.5.20+4

* Marker drag event

## 0.5.20+3

* Update Android play-services-maps to 17.0.0

## 0.5.20+2

* Android: Fix polyline width in building phase.

## 0.5.20+1

* Android: Unregister ActivityLifecycleCallbacks on activity destroy (fixes a memory leak).

## 0.5.20

* Add map toolbar support

## 0.5.19+2

* Fix polygons for iOS

## 0.5.19+1

* Fix polyline width according to device density

## 0.5.19


* Adds support for toggling Indoor View on or off.

* Allow BitmapDescriptor scaling override


## 0.5.18

* Fixed build issue on iOS.

## 0.5.17

* Add support for Padding.

## 0.5.16+1

* Update Dart code to conform to current Dart formatter.

## 0.5.16

* Add support for custom map styling.

## 0.5.15+1

* Add missing template type parameter to `invokeMethod` calls.
* Bump minimum Flutter version to 1.5.0.
* Replace invokeMethod with invokeMapMethod wherever necessary.

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
