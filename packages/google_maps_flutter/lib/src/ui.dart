// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter;

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

  static const LatLngCameraTargetBounds unbounded =
      const LatLngCameraTargetBounds(null);

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
/// "do not change this configuration item".
class GoogleMapOptions {
  final CameraPosition cameraPosition;
  final bool compassEnabled;
  final LatLngCameraTargetBounds latLngCameraTargetBounds;
  final MapType mapType;
  final MinMaxZoomPreference minMaxZoomPreference;
  final bool rotateGesturesEnabled;
  final bool scrollGesturesEnabled;
  final bool tiltGesturesEnabled;
  final bool trackCameraPosition;
  final bool zoomGesturesEnabled;

  const GoogleMapOptions({
    this.cameraPosition,
    this.compassEnabled,
    this.latLngCameraTargetBounds,
    this.mapType,
    this.minMaxZoomPreference,
    this.rotateGesturesEnabled,
    this.scrollGesturesEnabled,
    this.tiltGesturesEnabled,
    this.trackCameraPosition,
    this.zoomGesturesEnabled,
  });

  static const GoogleMapOptions defaultOptions = const GoogleMapOptions(
    compassEnabled: true,
    latLngCameraTargetBounds: LatLngCameraTargetBounds.unbounded,
    mapType: MapType.normal,
    minMaxZoomPreference: MinMaxZoomPreference.unbounded,
    rotateGesturesEnabled: true,
    scrollGesturesEnabled: true,
    tiltGesturesEnabled: true,
    trackCameraPosition: false,
    zoomGesturesEnabled: true,
  );

  GoogleMapOptions _updateWith(GoogleMapOptions change) {
    return new GoogleMapOptions(
      cameraPosition: change.cameraPosition ?? cameraPosition,
      compassEnabled: change.compassEnabled ?? compassEnabled,
      latLngCameraTargetBounds:
          change.latLngCameraTargetBounds ?? latLngCameraTargetBounds,
      mapType: change.mapType ?? mapType,
      minMaxZoomPreference: change.minMaxZoomPreference ?? minMaxZoomPreference,
      rotateGesturesEnabled:
          change.rotateGesturesEnabled ?? rotateGesturesEnabled,
      scrollGesturesEnabled:
          change.scrollGesturesEnabled ?? scrollGesturesEnabled,
      tiltGesturesEnabled: change.tiltGesturesEnabled ?? tiltGesturesEnabled,
      trackCameraPosition: change.trackCameraPosition ?? trackCameraPosition,
      zoomGesturesEnabled: change.zoomGesturesEnabled ?? zoomGesturesEnabled,
    );
  }

  dynamic _toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    if (cameraPosition != null)
      json['cameraPosition'] = cameraPosition._toJson();
    if (compassEnabled != null)
      json['compassEnabled'] = compassEnabled;
    if (latLngCameraTargetBounds != null)
      json['latLngCameraTargetBounds'] = latLngCameraTargetBounds._toJson();
    if (mapType != null)
      json['mapType'] = mapType.index;
    if (minMaxZoomPreference != null)
      json['minMaxZoomPreference'] = minMaxZoomPreference._toJson();
    if (rotateGesturesEnabled != null)
      json['rotateGesturesEnabled'] = rotateGesturesEnabled;
    if (scrollGesturesEnabled != null)
      json['scrollGesturesEnabled'] = scrollGesturesEnabled;
    if (tiltGesturesEnabled != null)
      json['tiltGesturesEnabled'] = tiltGesturesEnabled;
    if (trackCameraPosition != null)
      json['trackCameraPosition'] = trackCameraPosition;
    if (zoomGesturesEnabled != null)
      json['zoomGesturesEnabled'] = zoomGesturesEnabled;
    return json;
  }
}
