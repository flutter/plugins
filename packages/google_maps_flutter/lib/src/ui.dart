// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter;

/// Type of map tiles to display.
// Enum constants must be indexed to match the corresponding int constants of
// the Android platform API, see
// <https://developers.google.com/android/reference/com/google/android/gms/maps/GoogleMap.html#MAP_TYPE_NORMAL>
enum MapType {
  /// Do not display map tiles.
  none,

  /// Normal tiles (traffic and labels, subtle terrain information).
  normal,

  /// Satellite imaging tiles (aerial photos)
  satellite,

  /// Terrain tiles (indicates type and height of terrain)
  terrain,

  /// Hybrid tiles (satellite images with some labels/overlays)
  hybrid,
}

/// Bounds for the map camera target.
// Used with [GoogleMapOptions] to wrap a [LatLngBounds] value. This allows
// distinguishing between specifying an unbounded target (null `LatLngBounds`)
// from not specifying anything (null `CameraTargetBounds`).
class CameraTargetBounds {
  /// Creates a camera target bounds with the specified bounding box, or null
  /// to indicate that the camera target is not bounded.
  const CameraTargetBounds(this.bounds);

  /// The geographical bounding box for the map camera target.
  ///
  /// A null value means the camera target is unbounded.
  final LatLngBounds bounds;

  /// Unbounded camera target.
  static const CameraTargetBounds unbounded = CameraTargetBounds(null);

  dynamic _toJson() => <dynamic>[bounds?._toJson()];
}

/// Preferred bounds for map camera zoom level.
// Used with [GoogleMapOptions] to wrap min and max zoom. This allows
// distinguishing between specifying unbounded zooming (null `minZoom` and
// `maxZoom`) from not specifying anything (null `MinMaxZoomPreference`).
class MinMaxZoomPreference {
  const MinMaxZoomPreference(this.minZoom, this.maxZoom)
      : assert(minZoom == null || maxZoom == null || minZoom <= maxZoom);

  /// The preferred minimum zoom level or null, if unbounded from below.
  final double minZoom;

  /// The preferred maximum zoom level or null, if unbounded from above.
  final double maxZoom;

  /// Unbounded zooming.
  static const MinMaxZoomPreference unbounded =
      MinMaxZoomPreference(null, null);

  dynamic _toJson() => <dynamic>[minZoom, maxZoom];
}

/// Configuration options for the GoogleMaps user interface.
///
/// When used to change configuration, null values will be interpreted as
/// "do not change this configuration option".
class GoogleMapOptions {
  /// Creates a set of map user interface configuration options.
  ///
  /// By default, every non-specified field is null, meaning no desire to change
  /// user interface defaults or current configuration.
  GoogleMapOptions({
    this.cameraPosition,
    this.compassEnabled,
    this.cameraTargetBounds,
    this.mapType,
    this.minMaxZoomPreference,
    this.rotateGesturesEnabled,
    this.scrollGesturesEnabled,
    this.tiltGesturesEnabled,
    this.trackCameraPosition,
    this.zoomGesturesEnabled,
    this.myLocationEnabled,
  });

  /// The desired position of the map camera.
  ///
  /// This field is used to indicate initial camera position and to update that
  /// position programmatically along with other changes to the map user
  /// interface. It does not track the camera position through animations or
  /// reflect movements caused by user touch events.
  final CameraPosition cameraPosition;

  /// True if the map should show a compass when rotated.
  final bool compassEnabled;

  /// Geographical bounding box for the camera target.
  final CameraTargetBounds cameraTargetBounds;

  /// Type of map tiles to be rendered.
  final MapType mapType;

  /// Preferred bounds for the camera zoom level.
  ///
  /// Actual bounds depend on map data and device.
  final MinMaxZoomPreference minMaxZoomPreference;

  /// True if the map view should respond to rotate gestures.
  final bool rotateGesturesEnabled;

  /// True if the map view should respond to scroll gestures.
  final bool scrollGesturesEnabled;

  /// True if the map view should respond to tilt gestures.
  final bool tiltGesturesEnabled;

  /// True if the map view should relay camera move events to Flutter.
  final bool trackCameraPosition;

  /// True if the map view should respond to zoom gestures.
  final bool zoomGesturesEnabled;

  /// True if a "My Location" layer should be shown on the map.
  ///
  /// This layer includes a location indicator at the current device location,
  /// as well as a My Location button.
  /// * The indicator is a small blue dot if the device is stationary, or a
  /// chevron if the device is moving.
  /// * The My Location button animates to focus on the user's current location
  /// if the user's location is currently known.
  ///
  /// Enabling this feature requires adding location permissions to both native
  /// platforms of your app.
  /// * On Android add either
  /// `<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />`
  /// or `<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />`
  /// to your `AndroidManifest.xml` file. `ACCESS_COARSE_LOCATION` returns a
  /// location with an accuracy approximately equivalent to a city block, while
  /// `ACCESS_FINE_LOCATION` returns as precise a location as possible, although
  /// it consumes more battery power. You will also need to request these
  /// permissions during run-time. If they are not granted, the My Location
  /// feature will fail silently.
  /// * On iOS add a `NSLocationWhenInUseUsageDescription` key to your
  /// `Info.plist` file. This will automatically prompt the user for permissions
  /// when the map tries to turn on the My Location layer.
  final bool myLocationEnabled;

  /// Default user interface options.
  ///
  /// Specifies a map view that
  /// * displays a compass when rotated; [compassEnabled] is true
  /// * positions the camera at 0,0; [cameraPosition] has target `LatLng(0.0, 0.0)`
  /// * does not bound the camera target; [cameraTargetBounds] is `CameraTargetBounds.unbounded`
  /// * uses normal map tiles; [mapType] is `MapType.normal`
  /// * does not bound zooming; [minMaxZoomPreference] is `MinMaxZoomPreference.unbounded`
  /// * responds to rotate gestures; [rotateGesturesEnabled] is true
  /// * responds to scroll gestures; [scrollGesturesEnabled] is true
  /// * responds to tilt gestures; [tiltGesturesEnabled] is true
  /// * is silent about camera movement; [trackCameraPosition] is false
  /// * responds to zoom gestures; [zoomGesturesEnabled] is true
  /// * does not show user location; [myLocationEnabled] is false
  static final GoogleMapOptions defaultOptions = GoogleMapOptions(
    compassEnabled: true,
    cameraPosition: const CameraPosition(target: LatLng(0.0, 0.0)),
    cameraTargetBounds: CameraTargetBounds.unbounded,
    mapType: MapType.normal,
    minMaxZoomPreference: MinMaxZoomPreference.unbounded,
    rotateGesturesEnabled: true,
    scrollGesturesEnabled: true,
    tiltGesturesEnabled: true,
    trackCameraPosition: false,
    zoomGesturesEnabled: true,
    myLocationEnabled: false,
  );

  /// Creates a new options object whose values are the same as this instance,
  /// unless overwritten by the specified [changes].
  ///
  /// Returns this instance, if [changes] is null.
  GoogleMapOptions copyWith(GoogleMapOptions change) {
    if (change == null) {
      return this;
    }
    return GoogleMapOptions(
      cameraPosition: change.cameraPosition ?? cameraPosition,
      compassEnabled: change.compassEnabled ?? compassEnabled,
      cameraTargetBounds: change.cameraTargetBounds ?? cameraTargetBounds,
      mapType: change.mapType ?? mapType,
      minMaxZoomPreference: change.minMaxZoomPreference ?? minMaxZoomPreference,
      rotateGesturesEnabled:
          change.rotateGesturesEnabled ?? rotateGesturesEnabled,
      scrollGesturesEnabled:
          change.scrollGesturesEnabled ?? scrollGesturesEnabled,
      tiltGesturesEnabled: change.tiltGesturesEnabled ?? tiltGesturesEnabled,
      trackCameraPosition: change.trackCameraPosition ?? trackCameraPosition,
      zoomGesturesEnabled: change.zoomGesturesEnabled ?? zoomGesturesEnabled,
      myLocationEnabled: change.myLocationEnabled ?? myLocationEnabled,
    );
  }

  dynamic _toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};

    void addIfPresent(String fieldName, dynamic value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('cameraPosition', cameraPosition?._toJson());
    addIfPresent('compassEnabled', compassEnabled);
    addIfPresent('cameraTargetBounds', cameraTargetBounds?._toJson());
    addIfPresent('mapType', mapType?.index);
    addIfPresent('minMaxZoomPreference', minMaxZoomPreference?._toJson());
    addIfPresent('rotateGesturesEnabled', rotateGesturesEnabled);
    addIfPresent('scrollGesturesEnabled', scrollGesturesEnabled);
    addIfPresent('tiltGesturesEnabled', tiltGesturesEnabled);
    addIfPresent('trackCameraPosition', trackCameraPosition);
    addIfPresent('zoomGesturesEnabled', zoomGesturesEnabled);
    addIfPresent('myLocationEnabled', myLocationEnabled);
    return json;
  }
}
