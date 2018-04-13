// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_mobile_maps;

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

MapType _mapTypeFromJson(dynamic json) {
  if (json == null) {
    return null;
  }
  return MapType.values[json];
}

/// Bounds for the map camera target.
class CameraTargetBounds {
  static const CameraTargetBounds unbounded = const CameraTargetBounds(null);

  const CameraTargetBounds(this.bounds);

  /// The current bounds or null, if the camera target is unbounded.
  final LatLngBounds bounds;

  bool get isBounded => bounds != null;

  dynamic _toJson() => <dynamic>[bounds?._toJson()];

  static CameraTargetBounds _fromJson(dynamic json) {
    if (json == null) {
      return null;
    }
    return new CameraTargetBounds(LatLngBounds._fromJson(json[0]));
  }
}

/// Bounds for map camera zoom level.
class ZoomBounds {
  static const ZoomBounds unbounded = const ZoomBounds(null, null);

  const ZoomBounds(this.minZoom, this.maxZoom)
      : assert(minZoom == null || maxZoom == null || minZoom <= maxZoom);

  /// The current minimum zoom level or null, if unbounded from below.
  final double minZoom;

  /// The current maximum zoom level or null, if unbounded from above.
  final double maxZoom;

  bool get isBounded => minZoom != null || maxZoom != null;

  dynamic _toJson() => <dynamic>[minZoom, maxZoom];

  static ZoomBounds _fromJson(dynamic json) {
    if (json == null) {
      return null;
    }
    return new ZoomBounds(json[0], json[1]);
  }
}

/// Configuration options for the GoogleMaps user interface.
///
/// When used to change configuration, null values will be interpreted as
/// "do not change this configuration item". When used to represent current
/// configuration, all values will be non-null.
class GoogleMapOptions {
  final CameraPosition cameraPosition;
  final CameraTargetBounds cameraTargetBounds;
  final bool compassEnabled;
  final MapType mapType;
  final bool rotateGesturesEnabled;
  final bool scrollGesturesEnabled;
  final bool tiltGesturesEnabled;
  final ZoomBounds zoomBounds;
  final bool zoomGesturesEnabled;

  const GoogleMapOptions({
    this.cameraPosition,
    this.cameraTargetBounds,
    this.compassEnabled,
    this.mapType,
    this.rotateGesturesEnabled,
    this.scrollGesturesEnabled,
    this.tiltGesturesEnabled,
    this.zoomBounds,
    this.zoomGesturesEnabled,
  });

  static GoogleMapOptions _fromJson(dynamic json) {
    if (json == null) {
      return null;
    }
    return new GoogleMapOptions(
      cameraPosition: CameraPosition._fromJson(json['cameraPosition']),
      cameraTargetBounds:
          CameraTargetBounds._fromJson(json['cameraTargetBounds']),
      compassEnabled: json['compassEnabled'],
      mapType: _mapTypeFromJson(json['mapType']),
      rotateGesturesEnabled: json['rotateGesturesEnabled'],
      scrollGesturesEnabled: json['scrollGesturesEnabled'],
      tiltGesturesEnabled: json['tiltGesturesEnabled'],
      zoomBounds: ZoomBounds._fromJson(json['zoomBounds']),
      zoomGesturesEnabled: json['zoomGesturesEnabled'],
    );
  }

  dynamic _toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['cameraPosition'] = cameraPosition?._toJson();
    json['cameraTargetBounds'] = cameraTargetBounds?._toJson();
    json['compassEnabled'] = compassEnabled;
    json['mapType'] = mapType?.index;
    json['rotateGesturesEnabled'] = rotateGesturesEnabled;
    json['scrollGesturesEnabled'] = scrollGesturesEnabled;
    json['tiltGesturesEnabled'] = tiltGesturesEnabled;
    json['zoomBounds'] = zoomBounds?._toJson();
    json['zoomGesturesEnabled'] = zoomGesturesEnabled;
    return json;
  }
}
