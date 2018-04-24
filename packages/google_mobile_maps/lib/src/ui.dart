// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_mobile_maps;

/// Flags determining which camera move events are reported to Flutter.
class CameraMoveEvents {
  const CameraMoveEvents({
    this.onCameraMoveStarted = false,
    this.onCameraMoved = false,
    this.onCameraIdle = false,
  })  : assert(onCameraMoveStarted != null),
        assert(onCameraMoved != null),
        assert(onCameraIdle != null);

  final bool onCameraMoveStarted;
  final bool onCameraMoved;
  final bool onCameraIdle;

  static const CameraMoveEvents ignoreAll = const CameraMoveEvents();

  dynamic _toJson() =>
      <dynamic>[onCameraMoveStarted, onCameraMoved, onCameraIdle];
}

/// Type of map tiles to display.
///
/// Enum constants must be indexed to match the corresponding int constants of
/// the platform APIs, see
/// <https://developers.google.com/android/reference/com/google/android/gms/maps/GoogleMap.html#MAP_TYPE_NORMAL>
enum MapType {
  none,
  normal,
  satellite,
  terrain,
  hybrid,
}

/// Bounds for the map camera target.
class LatLngCameraTargetBounds {
  const LatLngCameraTargetBounds(this.bounds);

  /// The current bounds or null, if the camera target is unbounded.
  final LatLngBounds bounds;

  static const LatLngCameraTargetBounds unbounded = const LatLngCameraTargetBounds(null);

  dynamic _toJson() => <dynamic>[bounds?._toJson()];
}

/// Preferred bounds for map camera zoom level.
class MinMaxZoomPreference {
  const MinMaxZoomPreference(this.minZoom, this.maxZoom)
      : assert(minZoom == null || maxZoom == null || minZoom <= maxZoom);

  /// The current minimum zoom level or null, if unbounded from below.
  final double minZoom;

  /// The current maximum zoom level or null, if unbounded from above.
  final double maxZoom;

  static const MinMaxZoomPreference unbounded =
      const MinMaxZoomPreference(null, null);

  dynamic _toJson() => <dynamic>[minZoom, maxZoom];
}

/// Configuration options for the GoogleMaps user interface.
///
/// When used to change configuration, null values will be interpreted as
/// "do not change this configuration item". When used to represent current
/// configuration, all values will be non-null.
class GoogleMapOptions {
  final CameraMoveEvents cameraMoveEvents;
  final CameraPosition cameraPosition;
  final bool compassEnabled;
  final LatLngCameraTargetBounds latLngCameraTargetBounds;
  final MapType mapType;
  final MinMaxZoomPreference minMaxZoomPreference;
  final bool rotateGesturesEnabled;
  final bool scrollGesturesEnabled;
  final bool tiltGesturesEnabled;
  final bool zoomGesturesEnabled;

  const GoogleMapOptions({
    this.cameraMoveEvents,
    this.cameraPosition,
    this.compassEnabled,
    this.latLngCameraTargetBounds,
    this.mapType,
    this.minMaxZoomPreference,
    this.rotateGesturesEnabled,
    this.scrollGesturesEnabled,
    this.tiltGesturesEnabled,
    this.zoomGesturesEnabled,
  });

  static const GoogleMapOptions defaultOptions = const GoogleMapOptions(
    cameraMoveEvents: CameraMoveEvents.ignoreAll,
    compassEnabled: true,
    latLngCameraTargetBounds: LatLngCameraTargetBounds.unbounded,
    mapType: MapType.normal,
    minMaxZoomPreference: MinMaxZoomPreference.unbounded,
    rotateGesturesEnabled: true,
    scrollGesturesEnabled: true,
    tiltGesturesEnabled: true,
    zoomGesturesEnabled: true,
  );

  GoogleMapOptions _updateWith(GoogleMapOptions change) {
    return new GoogleMapOptions(
      cameraMoveEvents: change.cameraMoveEvents ?? cameraMoveEvents,
      cameraPosition: change.cameraPosition ?? cameraPosition,
      latLngCameraTargetBounds:
          change.latLngCameraTargetBounds ?? latLngCameraTargetBounds,
      compassEnabled: change.compassEnabled ?? compassEnabled,
      mapType: change.mapType ?? mapType,
      rotateGesturesEnabled:
          change.rotateGesturesEnabled ?? rotateGesturesEnabled,
      scrollGesturesEnabled:
          change.scrollGesturesEnabled ?? scrollGesturesEnabled,
      tiltGesturesEnabled: change.tiltGesturesEnabled ?? tiltGesturesEnabled,
      minMaxZoomPreference: change.minMaxZoomPreference ?? minMaxZoomPreference,
      zoomGesturesEnabled: change.zoomGesturesEnabled ?? zoomGesturesEnabled,
    );
  }

  dynamic _toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['cameraMoveEvents'] = cameraMoveEvents?._toJson();
    json['cameraPosition'] = cameraPosition?._toJson();
    json['latLngCameraTargetBounds'] = latLngCameraTargetBounds?._toJson();
    json['compassEnabled'] = compassEnabled;
    json['mapType'] = mapType?.index;
    json['minMaxZoomPreference'] = minMaxZoomPreference?._toJson();
    json['rotateGesturesEnabled'] = rotateGesturesEnabled;
    json['scrollGesturesEnabled'] = scrollGesturesEnabled;
    json['tiltGesturesEnabled'] = tiltGesturesEnabled;
    json['zoomGesturesEnabled'] = zoomGesturesEnabled;
    return json;
  }
}
