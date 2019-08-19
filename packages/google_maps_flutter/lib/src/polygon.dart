// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter;

/// Uniquely identifies a [Polygon] among [GoogleMap] polygons.
///
/// This does not have to be globally unique, only unique among the list.
@immutable
class PolygonId {
  PolygonId(this.value) : assert(value != null);

  /// value of the [PolygonId].
  final String value;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final PolygonId typedOther = other;
    return value == typedOther.value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return 'PolygonId{value: $value}';
  }
}

/// Draws a polygon through geographical locations on the map.
@immutable
class Polygon {
  const Polygon({
    @required this.polygonId,
    this.consumeTapEvents = false,
    this.fillColor = Colors.black,
    this.geodesic = false,
    this.points = const <LatLng>[],
    this.strokeColor = Colors.black,
    this.strokeWidth = 10,
    this.visible = true,
    this.zIndex = 0,
    this.onTap,
  });

  /// Uniquely identifies a [Polygon].
  final PolygonId polygonId;

  /// True if the [Polygon] consumes tap events.
  ///
  /// If this is false, [onTap] callback will not be triggered.
  final bool consumeTapEvents;

  /// Fill color in ARGB format, the same format used by Color. The default value is black (0xff000000).
  final Color fillColor;

  /// Indicates whether the segments of the polygon should be drawn as geodesics, as opposed to straight lines
  /// on the Mercator projection.
  ///
  /// A geodesic is the shortest path between two points on the Earth's surface.
  /// The geodesic curve is constructed assuming the Earth is a sphere
  final bool geodesic;

  /// The vertices of the polygon to be drawn.
  ///
  /// Line segments are drawn between consecutive points. A polygon is not closed by
  /// default; to form a closed polygon, the start and end points must be the same.
  final List<LatLng> points;

  /// True if the marker is visible.
  final bool visible;

  /// Line color in ARGB format, the same format used by Color. The default value is black (0xff000000).
  final Color strokeColor;

  /// Width of the polygon, used to define the width of the line to be drawn.
  ///
  /// The width is constant and independent of the camera's zoom level.
  /// The default value is 10.
  final int strokeWidth;

  /// The z-index of the polygon, used to determine relative drawing order of
  /// map overlays.
  ///
  /// Overlays are drawn in order of z-index, so that lower values means drawn
  /// earlier, and thus appearing to be closer to the surface of the Earth.
  final int zIndex;

  /// Callbacks to receive tap events for polygon placed on this map.
  final VoidCallback onTap;

  /// Creates a new [Polygon] object whose values are the same as this instance,
  /// unless overwritten by the specified parameters.
  Polygon copyWith({
    bool consumeTapEventsParam,
    Color fillColorParam,
    bool geodesicParam,
    List<LatLng> pointsParam,
    Color strokeColorParam,
    int strokeWidthParam,
    bool visibleParam,
    int zIndexParam,
    VoidCallback onTapParam,
  }) {
    return Polygon(
      polygonId: polygonId,
      consumeTapEvents: consumeTapEventsParam ?? consumeTapEvents,
      fillColor: fillColorParam ?? fillColor,
      geodesic: geodesicParam ?? geodesic,
      points: pointsParam ?? points,
      strokeColor: strokeColorParam ?? strokeColor,
      strokeWidth: strokeWidthParam ?? strokeWidth,
      visible: visibleParam ?? visible,
      onTap: onTapParam ?? onTap,
      zIndex: zIndexParam ?? zIndex,
    );
  }

  dynamic _toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};

    void addIfPresent(String fieldName, dynamic value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('polygonId', polygonId.value);
    addIfPresent('consumeTapEvents', consumeTapEvents);
    addIfPresent('fillColor', fillColor.value);
    addIfPresent('geodesic', geodesic);
    addIfPresent('strokeColor', strokeColor.value);
    addIfPresent('strokeWidth', strokeWidth);
    addIfPresent('visible', visible);
    addIfPresent('zIndex', zIndex);

    if (points != null) {
      json['points'] = _pointsToJson();
    }

    return json;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final Polygon typedOther = other;
    return polygonId == typedOther.polygonId;
  }

  @override
  int get hashCode => polygonId.hashCode;

  dynamic _pointsToJson() {
    final List<dynamic> result = <dynamic>[];
    for (final LatLng point in points) {
      result.add(point._toJson());
    }
    return result;
  }
}

Map<PolygonId, Polygon> _keyByPolygonId(Iterable<Polygon> polygons) {
  if (polygons == null) {
    return <PolygonId, Polygon>{};
  }
  return Map<PolygonId, Polygon>.fromEntries(polygons.map((Polygon polygon) =>
      MapEntry<PolygonId, Polygon>(polygon.polygonId, polygon)));
}

List<Map<String, dynamic>> _serializePolygonSet(Set<Polygon> polygons) {
  if (polygons == null) {
    return null;
  }
  return polygons
      .map<Map<String, dynamic>>((Polygon p) => p._toJson())
      .toList();
}
