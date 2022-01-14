// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart'
    show immutable, listEquals, VoidCallback;
import 'package:flutter/material.dart' show Color, Colors;

import 'types.dart';

/// Uniquely identifies a [Polygon] among [GoogleMap] polygons.
///
/// This does not have to be globally unique, only unique among the list.
@immutable
class PolygonId extends MapsObjectId<Polygon> {
  /// Creates an immutable identifier for a [Polygon].
  const PolygonId(String value) : super(value);
}

/// Draws a polygon through geographical locations on the map.
@immutable
class Polygon implements MapsObject {
  /// Creates an immutable representation of a polygon through geographical locations on the map.
  const Polygon({
    required this.polygonId,
    this.consumeTapEvents = false,
    this.fillColor = Colors.black,
    this.geodesic = false,
    this.points = const <LatLng>[],
    this.holes = const <List<LatLng>>[],
    this.strokeColor = Colors.black,
    this.strokeWidth = 10,
    this.visible = true,
    this.zIndex = 0,
    this.onTap,
  });

  /// Uniquely identifies a [Polygon].
  final PolygonId polygonId;

  @override
  PolygonId get mapsId => polygonId;

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

  /// To create an empty area within a polygon, you need to use holes.
  /// To create the hole, the coordinates defining the hole path must be inside the polygon.
  ///
  /// The vertices of the holes to be cut out of polygon.
  ///
  /// Line segments of each points of hole are drawn inside polygon between consecutive hole points.
  final List<List<LatLng>> holes;

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
  final VoidCallback? onTap;

  /// Creates a new [Polygon] object whose values are the same as this instance,
  /// unless overwritten by the specified parameters.
  Polygon copyWith({
    bool? consumeTapEventsParam,
    Color? fillColorParam,
    bool? geodesicParam,
    List<LatLng>? pointsParam,
    List<List<LatLng>>? holesParam,
    Color? strokeColorParam,
    int? strokeWidthParam,
    bool? visibleParam,
    int? zIndexParam,
    VoidCallback? onTapParam,
  }) {
    return Polygon(
      polygonId: polygonId,
      consumeTapEvents: consumeTapEventsParam ?? consumeTapEvents,
      fillColor: fillColorParam ?? fillColor,
      geodesic: geodesicParam ?? geodesic,
      points: pointsParam ?? points,
      holes: holesParam ?? holes,
      strokeColor: strokeColorParam ?? strokeColor,
      strokeWidth: strokeWidthParam ?? strokeWidth,
      visible: visibleParam ?? visible,
      onTap: onTapParam ?? onTap,
      zIndex: zIndexParam ?? zIndex,
    );
  }

  /// Creates a new [Polygon] object whose values are the same as this instance.
  Polygon clone() {
    return copyWith(pointsParam: List<LatLng>.of(points));
  }

  /// Converts this object to something serializable in JSON.
  Object toJson() {
    final Map<String, Object> json = <String, Object>{};

    void addIfPresent(String fieldName, Object? value) {
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

    if (holes != null) {
      json['holes'] = _holesToJson();
    }

    return json;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final Polygon typedOther = other as Polygon;
    return polygonId == typedOther.polygonId &&
        consumeTapEvents == typedOther.consumeTapEvents &&
        fillColor == typedOther.fillColor &&
        geodesic == typedOther.geodesic &&
        listEquals(points, typedOther.points) &&
        const DeepCollectionEquality().equals(holes, typedOther.holes) &&
        visible == typedOther.visible &&
        strokeColor == typedOther.strokeColor &&
        strokeWidth == typedOther.strokeWidth &&
        zIndex == typedOther.zIndex;
  }

  @override
  int get hashCode => polygonId.hashCode;

  Object _pointsToJson() {
    final List<Object> result = <Object>[];
    for (final LatLng point in points) {
      result.add(point.toJson());
    }
    return result;
  }

  List<List<Object>> _holesToJson() {
    final List<List<Object>> result = <List<Object>>[];
    for (final List<LatLng> hole in holes) {
      final List<Object> jsonHole = <Object>[];
      for (final LatLng point in hole) {
        jsonHole.add(point.toJson());
      }
      result.add(jsonHole);
    }
    return result;
  }
}
