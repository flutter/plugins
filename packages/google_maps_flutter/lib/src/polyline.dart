// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter;

/// A polyline is a vector drawnat a particular geographical location on the map's surface.
/// A polyline spans a number of geographical points
///
/// Polylines are owned by a single [GoogleMapController] which fires events
/// as polylines are added, updated, tapped, and removed.
@immutable
class Polyline {
  const Polyline({
    @required this.polylineId,
    this.points,
    this.clickable,
    this.color,
    this.endCap,
    this.geodesic,
    this.jointType,
    this.pattern,
    this.startCap,
    this.visible,
    this.width,
    this.zIndex,
    this.onTap,
  });

  final PolylineId polylineId;

  /// Adds a vertex to the end of the polyline being built.
  ///
  /// The vector will be drawn from point to point
  final List<LatLng> points;

  /// True if the polyline is clickable
  final bool clickable;

  /// Sets the color of the polyline as a 32-bit ARGB color.
  final int color;

  /// Sets the cap at the end vertex of the polyline
  final Cap endCap;

  /// Specifies whether to draw each segment of this polyline as a geodesic.
  final bool geodesic;

  /// Sets the joint type for all vertices of the polyline except the start and end vertices.
  final JointType jointType;

  /// Sets the stroke pattern for the polyline.
  final List<Pattern> pattern;

  /// Sets the cap at the start vertex of the polyline
  final Cap startCap;

  /// Sets the width of the polyline
  final double width;

  /// True if the polyline is visible.
  final bool visible;

  /// The z-index of the polyline, used to determine relative drawing order of
  /// map overlays.
  ///
  /// Overlays are drawn in order of z-index, so that lower values means drawn
  /// earlier, and thus appearing to be closer to the surface of the Earth.
  final double zIndex;

  /// Callbacks to receive tap events for polylines placed on this map.
  final VoidCallback onTap;

  /// Creates a new options object whose values are the same as this instance,
  /// unless overwritten by the specified [changes].
  ///
  /// Returns this instance, if [changes] is null.
  Polyline copyWith({
    List<LatLng> pointsParam,
    bool clickableParam,
    int colorParam,
    Cap endCapParam,
    bool geodesicParam,
    JointType jointTypeParam,
    List<Pattern> patternParam,
    Cap startCapParam,
    bool visibleParam,
    double widthParam,
    double zIndexParam,
    VoidCallback onTapParam,
  }) {
    return Polyline(
      polylineId: polylineId,
      points: pointsParam ?? points,
      clickable: clickableParam ?? clickable,
      color: colorParam ?? color,
      endCap: endCapParam ?? endCap,
      geodesic: geodesicParam ?? geodesic,
      jointType: jointTypeParam ?? jointType,
      pattern: patternParam ?? pattern,
      startCap: startCapParam ?? startCap,
      visible: visibleParam ?? visible,
      width: widthParam ?? width,
      zIndex: zIndexParam ?? zIndex,
      onTap: onTapParam ?? onTap,
    );
  }

  dynamic _toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};

    void addIfPresent(String fieldName, dynamic value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    final List<dynamic> pointsJson = <dynamic>[];
    if (points != null) {
      for (int i = 0; i < points.length; i++) {
        pointsJson.add(points[i]._toJson());
      }
    }

    final List<dynamic> patternsJson = <dynamic>[];
    if (pattern != null) {
      for (int i = 0; i < pattern.length; i++) {
        patternsJson.add(pattern[i]._toJson());
      }
    }

    addIfPresent('polylineId', polylineId.value);
    addIfPresent('points', pointsJson);
    addIfPresent('clickable', clickable);
    addIfPresent('color', color);
    addIfPresent('endCap', endCap?.toString());
    addIfPresent('geodesic', geodesic);
    addIfPresent('jointType', jointType?.toString());
    addIfPresent('pattern', patternsJson);
    addIfPresent('startCap', startCap?.toString());
    addIfPresent('visible', visible);
    addIfPresent('width', width);
    addIfPresent('zIndex', zIndex);
    return json;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final Polyline typedOther = other;
    return polylineId == typedOther.polylineId;
  }

  @override
  int get hashCode => polylineId.hashCode;

  @override
  String toString() {
    return 'Polyline{polylineId: $polylineId, points: $points, clickable: $clickable, color: $color, endCap: $endCap, geodesic: $geodesic, jointType: $jointType, pattern: $pattern, startCap: $startCap, visible: $visible, width: $width, zIndex: $zIndex, onTap: $onTap}';
  }
}

enum Cap { ButtCap, RoundCap, SquareCap }
enum PatternItem { Dash, Dot, Gap }

class Pattern {
  const Pattern({
    this.length,
    this.patternItem,
  });

  final int length;
  final PatternItem patternItem;

  dynamic _toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['length'] = length;
    json['pattern'] = patternItem.toString();
    return json;
  }
}

enum JointType { Bevel, Default, Route }

class PolylineId {
  PolylineId(this.value) : assert(value != null);

  /// value of the [PolylineId].
  final String value;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final PolylineId typedOther = other;
    return value == typedOther.value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return 'PolylineId{value: $value}';
  }
}

Map<PolylineId, Polyline> _keyByPolylineId(Iterable<Polyline> polylines) {
  if (polylines == null) {
    return <PolylineId, Polyline>{};
  }
  return Map<PolylineId, Polyline>.fromEntries(polylines.map(
      (Polyline polyline) =>
          MapEntry<PolylineId, Polyline>(polyline.polylineId, polyline)));
}

List<Map<String, dynamic>> _serializePolylineSet(Set<Polyline> polylines) {
  if (polylines == null) {
    return null;
  }
  return polylines
      .map<Map<String, dynamic>>((Polyline m) => m._toJson())
      .toList();
}
