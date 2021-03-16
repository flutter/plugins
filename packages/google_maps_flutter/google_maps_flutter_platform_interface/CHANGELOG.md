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
