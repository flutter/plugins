## 0.4.0+1

* Updates `README.md` to describe a hit-testing issue when Flutter widgets are overlaid on top of the Map widget.

## 0.4.0

* Implements the new platform interface versions of `buildView` and
  `updateOptions` with structured option types.
* **BREAKING CHANGE**: No longer implements the unstructured option dictionary
  versions of those methods, so this version can only be used with
  `google_maps_flutter` 2.1.8 or later.
* Adds `const` constructor parameters in example tests.

## 0.3.3

* Removes custom `analysis_options.yaml` (and fixes code to comply with newest rules).
* Updates `package:google_maps` dependency to latest (`^6.1.0`).
* Ensures that `convert.dart` sanitizes user-created HTML before passing it to the
  Maps JS SDK with `sanitizeHtml` from `package:sanitize_html`.
  [More info](https://pub.dev/documentation/sanitize_html/latest/sanitize_html/sanitizeHtml.html).

## 0.3.2+2

* Removes unnecessary imports.
* Fixes library_private_types_in_public_api, sort_child_properties_last and use_key_in_widget_constructors
  lint warnings.

## 0.3.2+1

* Removes dependency on `meta`.

## 0.3.2

* Add `onDragStart` and `onDrag` to `Marker`

## 0.3.1

* Fix the `getScreenCoordinate(LatLng)` method. [#80710](https://github.com/flutter/flutter/issues/80710)
* Wait until the map tiles have loaded before calling `onPlatformViewCreated`, so
the returned controller is 100% functional (has bounds, a projection, etc...)
* Use zIndex property when initializing Circle objects. [#89374](https://github.com/flutter/flutter/issues/89374)

## 0.3.0+4

* Add `implements` to pubspec.

## 0.3.0+3

* Update the `README.md` usage instructions to not be tied to explicit package versions.

## 0.3.0+2

* Document `liteModeEnabled` is not available on the web. [#83737](https://github.com/flutter/flutter/issues/83737).

## 0.3.0+1

* Change sizing code of `GoogleMap` widget's `HtmlElementView` so it works well when slotted.

## 0.3.0

* Migrate package to null-safety.
* **Breaking changes:**
  * The property `icon` of a `Marker` cannot be `null`. Defaults to `BitmapDescriptor.defaultMarker`
  * The property `initialCameraPosition` of a `GoogleMapController` can't be `null`. It is also marked as `required`.
  * The parameter `creationId` of the `buildView` method cannot be `null` (this should be handled internally for users of the plugin)
  * Most of the Controller methods can't be called after `remove`/`dispose`. Calling these methods now will throw an Assertion error. Before it'd be a no-op, or a null-pointer exception.

## 0.2.1

* Move integration tests to `example`.
* Tweak pubspec dependencies for main package.

## 0.2.0

* Make this plugin compatible with the rest of null-safe plugins.
* Noop tile overlays methods, so they don't crash on web.

**NOTE**: This plugin is **not** null-safe yet!

## 0.1.2

* Update min Flutter SDK to 1.20.0.

## 0.1.1

* Auto-reverse holes if they're the same direction as the polygon. [Issue](https://github.com/flutter/flutter/issues/74096).

## 0.1.0+10

* Update `package:google_maps_flutter_platform_interface` to `^1.1.0`.
* Add support for Polygon Holes.

## 0.1.0+9

* Update Flutter SDK constraint.

## 0.1.0+8

* Update `package:google_maps_flutter_platform_interface` to `^1.0.5`.
* Add support for `fromBitmap` BitmapDescriptors. [Issue](https://github.com/flutter/flutter/issues/66622).

## 0.1.0+7

* Substitute `undefined_prefixed_name: ignore` analyzer setting by a `dart:ui` shim with conditional exports. [Issue](https://github.com/flutter/flutter/issues/69309).

## 0.1.0+6

* Ensure a single `InfoWindow` is shown at a time. [Issue](https://github.com/flutter/flutter/issues/67380).

## 0.1.0+5

* Update `package:google_maps` to `^3.4.5`.
* Fix `GoogleMapController.getLatLng()`. [Issue](https://github.com/flutter/flutter/issues/67606).
* Make `InfoWindow` contents clickable so `onTap` works as advertised. [Issue](https://github.com/flutter/flutter/issues/67289).
* Fix `InfoWindow` snippets when converting initial markers. [Issue](https://github.com/flutter/flutter/issues/67854).

## 0.1.0+4

* Update `package:sanitize_html` to `^1.4.1` to prevent [a crash](https://github.com/flutter/flutter/issues/67854) when InfoWindow title/snippet have links.

## 0.1.0+3

* Fix crash when converting initial polylines and polygons. [Issue](https://github.com/flutter/flutter/issues/65152).
* Correctly convert Colors when rendering polylines, polygons and circles. [Issue](https://github.com/flutter/flutter/issues/67032).

## 0.1.0+2

* Fix crash when converting Markers with icon explicitly set to null. [Issue](https://github.com/flutter/flutter/issues/64938).

## 0.1.0+1

* Port e2e tests to use the new integration_test package.

## 0.1.0

* First open-source version
