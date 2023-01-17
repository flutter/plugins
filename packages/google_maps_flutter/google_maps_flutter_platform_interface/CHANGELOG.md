## 2.2.5

* Updates code for stricter lint checks.

## 2.2.4

* Updates code for `no_leading_underscores_for_local_identifiers` lint.

## 2.2.3

* Updates imports for `prefer_relative_imports`.
* Updates minimum Flutter version to 2.10.

## 2.2.2

* Adds a `size` parameter to `BitmapDescriptor.fromBytes`, so **web** applications
  can specify the actual *physical size* of the bitmap. The parameter is not needed
  (and ignored) in other platforms. Issue [#73789](https://github.com/flutter/flutter/issues/73789).
* Fixes avoid_redundant_argument_values lint warnings and minor typos.

## 2.2.1

* Adds a new interface for inspecting the platform map state in tests.

## 2.2.0

* Adds new versions of `buildView` and `updateOptions` that take a new option
  class instead of a dictionary, to remove the cross-package dependency on
  magic string keys.
* Adopts several parameter objects in the new `buildView` variant to
  future-proof it against future changes.
* Ignores unnecessary import warnings in preparation for [upcoming Flutter changes](https://github.com/flutter/flutter/pull/104231).

## 2.1.7

* Updates code for stricter analysis options.
* Removes unnecessary imports.

## 2.1.6

* Migrates from `ui.hash*` to `Object.hash*`.
* Updates minimum Flutter version to 2.5.0.

## 2.1.5

Removes dependency on `meta`.

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
