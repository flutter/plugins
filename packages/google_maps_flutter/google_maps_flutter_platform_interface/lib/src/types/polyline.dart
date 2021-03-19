// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart' show listEquals, VoidCallback;
import 'package:flutter/material.dart' show Color, Colors;
import 'package:meta/meta.dart' show immutable;

import 'types.dart';

/// Uniquely identifies a [Polyline] among [GoogleMap] polylines.
///
/// This does not have to be globally unique, only unique among the list.
@immutable
class PolylineId extends MapsObjectId<Polyline> {
  /// Creates an immutable object representing a [PolylineId] among [GoogleMap] polylines.
  ///
  /// An [AssertionError] will be thrown if [value] is null.
  const PolylineId(String value) : super(value);
}

/// Draws a line through geographical locations on the map.
@immutable
class Polyline implements MapsObject {
  /// Creates an immutable object representing a line drawn through geographical locations on the map.
  const Polyline({
    required this.polylineId,
    this.consumeTapEvents = false,
    this.color = Colors.black,
    this.endCap = Cap.buttCap,
    this.geodesic = false,
    this.jointType = JointType.mitered,
    this.points = const <LatLng>[],
    this.patterns = const <PatternItem>[],
    this.startCap = Cap.buttCap,
    this.visible = true,
    this.width = 10,
    this.zIndex = 0,
    this.onTap,
  });

  /// Uniquely identifies a [Polyline].
  final PolylineId polylineId;

  @override
  PolylineId get mapsId => polylineId;

  /// True if the [Polyline] consumes tap events.
  ///
  /// If this is false, [onTap] callback will not be triggered.
  final bool consumeTapEvents;

  /// Line segment color in ARGB format, the same format used by Color. The default value is black (0xff000000).
  final Color color;

  /// Indicates whether the segments of the polyline should be drawn as geodesics, as opposed to straight lines
  /// on the Mercator projection.
  ///
  /// A geodesic is the shortest path between two points on the Earth's surface.
  /// The geodesic curve is constructed assuming the Earth is a sphere
  final bool geodesic;

  /// Joint type of the polyline line segments.
  ///
  /// The joint type defines the shape to be used when joining adjacent line segments at all vertices of the
  /// polyline except the start and end vertices. See [JointType] for supported joint types. The default value is
  /// mitered.
  ///
  /// Supported on Android only.
  final JointType jointType;

  /// The stroke pattern for the polyline.
  ///
  /// Solid or a sequence of PatternItem objects to be repeated along the line.
  /// Available PatternItem types: Gap (defined by gap length in pixels), Dash (defined by line width and dash
  /// length in pixels) and Dot (circular, centered on the line, diameter defined by line width in pixels).
  final List<PatternItem> patterns;

  /// The vertices of the polyline to be drawn.
  ///
  /// Line segments are drawn between consecutive points. A polyline is not closed by
  /// default; to form a closed polyline, the start and end points must be the same.
  final List<LatLng> points;

  /// The cap at the start vertex of the polyline.
  ///
  /// The default start cap is ButtCap.
  ///
  /// Supported on Android only.
  final Cap startCap;

  /// The cap at the end vertex of the polyline.
  ///
  /// The default end cap is ButtCap.
  ///
  /// Supported on Android only.
  final Cap endCap;

  /// True if the marker is visible.
  final bool visible;

  /// Width of the polyline, used to define the width of the line segment to be drawn.
  ///
  /// The width is constant and independent of the camera's zoom level.
  /// The default value is 10.
  final int width;

  /// The z-index of the polyline, used to determine relative drawing order of
  /// map overlays.
  ///
  /// Overlays are drawn in order of z-index, so that lower values means drawn
  /// earlier, and thus appearing to be closer to the surface of the Earth.
  final int zIndex;

  /// Callbacks to receive tap events for polyline placed on this map.
  final VoidCallback? onTap;

  /// Creates a new [Polyline] object whose values are the same as this instance,
  /// unless overwritten by the specified parameters.
  Polyline copyWith({
    Color? colorParam,
    bool? consumeTapEventsParam,
    Cap? endCapParam,
    bool? geodesicParam,
    JointType? jointTypeParam,
    List<PatternItem>? patternsParam,
    List<LatLng>? pointsParam,
    Cap? startCapParam,
    bool? visibleParam,
    int? widthParam,
    int? zIndexParam,
    VoidCallback? onTapParam,
  }) {
    return Polyline(
      polylineId: polylineId,
      color: colorParam ?? color,
      consumeTapEvents: consumeTapEventsParam ?? consumeTapEvents,
      endCap: endCapParam ?? endCap,
      geodesic: geodesicParam ?? geodesic,
      jointType: jointTypeParam ?? jointType,
      patterns: patternsParam ?? patterns,
      points: pointsParam ?? points,
      startCap: startCapParam ?? startCap,
      visible: visibleParam ?? visible,
      width: widthParam ?? width,
      onTap: onTapParam ?? onTap,
      zIndex: zIndexParam ?? zIndex,
    );
  }

  /// Creates a new [Polyline] object whose values are the same as this
  /// instance.
  Polyline clone() {
    return copyWith(
      patternsParam: List<PatternItem>.of(patterns),
      pointsParam: List<LatLng>.of(points),
    );
  }

  /// Converts this object to something serializable in JSON.
  Object toJson() {
    final Map<String, Object> json = <String, Object>{};

    void addIfPresent(String fieldName, Object? value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('polylineId', polylineId.value);
    addIfPresent('consumeTapEvents', consumeTapEvents);
    addIfPresent('color', color.value);
    addIfPresent('endCap', endCap.toJson());
    addIfPresent('geodesic', geodesic);
    addIfPresent('jointType', jointType.value);
    addIfPresent('startCap', startCap.toJson());
    addIfPresent('visible', visible);
    addIfPresent('width', width);
    addIfPresent('zIndex', zIndex);

    if (points != null) {
      json['points'] = _pointsToJson();
    }

    if (patterns != null) {
      json['pattern'] = _patternToJson();
    }

    return json;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final Polyline typedOther = other as Polyline;
    return polylineId == typedOther.polylineId &&
        consumeTapEvents == typedOther.consumeTapEvents &&
        color == typedOther.color &&
        geodesic == typedOther.geodesic &&
        jointType == typedOther.jointType &&
        listEquals(patterns, typedOther.patterns) &&
        listEquals(points, typedOther.points) &&
        startCap == typedOther.startCap &&
        endCap == typedOther.endCap &&
        visible == typedOther.visible &&
        width == typedOther.width &&
        zIndex == typedOther.zIndex;
  }

  @override
  int get hashCode => polylineId.hashCode;

  Object _pointsToJson() {
    final List<Object> result = <Object>[];
    for (final LatLng point in points) {
      result.add(point.toJson());
    }
    return result;
  }

  Object _patternToJson() {
    final List<Object> result = <Object>[];
    for (final PatternItem patternItem in patterns) {
      if (patternItem != null) {
        result.add(patternItem.toJson());
      }
    }
    return result;
  }
}
