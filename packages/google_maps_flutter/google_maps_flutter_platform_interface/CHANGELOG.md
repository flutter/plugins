## 2.1.4

* Update to use the `verify` method introduced in plugin_platform_interface 2.1.0.

## 2.1.3

* `LatLng` constructor maintains longitude precision when given within
  acceptable range

## 2.1.2

* Add additional marker drag events

## 2.1.1

* Method `buildViewWithTextDirection` has been added to the platform interface.

## 2.1.0

* Add support for Hybrid Composition when building the Google Maps widget on Android. Set
  `MethodChannelGoogleMapsFlutter.useAndroidViewSurface` to `true` to build with Hybrid Composition.

## 2.0.4

* Preserve the `TileProvider` when copying `TileOverlay`, fixing a
  regression with tile overlays introduced in the null safety migration.

## 2.0.3

* Fix type issues in `isMarkerInfoWindowShown` and `getZoomLevel` introduced
  in the null safety migration.

## 2.0.2

* Mark constructors for CameraUpdate, CircleId, MapsObjectId, MarkerId, PolygonId, PolylineId and TileOverlayId as const

## 2.0.1

* Update platform_plugin_interface version requirement.

## 2.0.0

* Migrated to null-safety.
* BREAKING CHANGE: Removed deprecated APIs.
* BREAKING CHANGE: Many sets in APIs that used to treat null and empty set as
  equivalent now require passing an empty set.
* BREAKING CHANGE: toJson now always returns an `Object`; the details of the
  object type and structure should be treated as an implementation detail.

## 1.2.0

* Add TileOverlay support.

## 1.1.0

* Add support for holes in Polygons.

## 1.0.6

* Update Flutter SDK constraint.

## 1.0.5

* Temporarily add a `fromJson` constructor to `BitmapDescriptor` so serialized descriptors can be synchronously re-hydrated. This will be removed when a fix for [this issue](https://github.com/flutter/flutter/issues/70330) lands.

## 1.0.4

* Add a `dispose` method to the interface, so implementations may cleanup resources acquired on `init`.

## 1.0.3

* Pass icon width/height if present on `fromAssetImage` BitmapDescriptors (web only)

## 1.0.2

* Update lower bound of dart dependency to 2.1.0.

## 1.0.1

* Initial open source release.

## 1.0.0 ... 1.0.0+5

* Development.
