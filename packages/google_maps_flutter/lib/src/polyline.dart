// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter;

/// A polyline is a vector drawnat a particular geographical location on the map's surface.
/// A polyline spans a number of geographical points
///
/// Polylines are owned by a single [GoogleMapController] which fires events
/// as polylines are added, updated, tapped, and removed.
class Polyline {
  @visibleForTesting
  Polyline(this._id, this._options);

  /// A unique identifier for this Polyline.
  ///
  /// The identirifer is an arbitrary unique string.
  final String _id;
  String get id => _id;

  PolylineOptions _options;

  /// The polyline configuration options most recently applied programmatically
  /// via the map controller.
  ///
  /// The returned value does not reflect any changes made to the polyline through
  /// touch events. Add listeners to the owning map controller to track those.
  PolylineOptions get options => _options;
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

/// Configuration options for [Marker] instances.
///
/// When used to change configuration, null values will be interpreted as
/// "do not change this configuration option".
class PolylineOptions {
  /// Creates a set of polyline configuration options.
  ///
  /// By default, every non-specified field is null, meaning no desire to change
  /// polyline defaults or current configuration.
  const PolylineOptions({
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
  });

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

  /// True if the marker is visible.
  final bool visible;

  /// The z-index of the marker, used to determine relative drawing order of
  /// map overlays.
  ///
  /// Overlays are drawn in order of z-index, so that lower values means drawn
  /// earlier, and thus appearing to be closer to the surface of the Earth.
  final double zIndex;

  /// Default marker options.
  ///
  /// Specifies a marker that
  /// * is visible; [visible] is true
  /// * is placed at the base of the drawing order; [zIndex] is 0.0
  static const PolylineOptions defaultOptions = PolylineOptions(
    points: <LatLng>[
      LatLng(0.0, 0.0),
      LatLng(1.0, 1.0),
    ],
    clickable: true,
    color: 0xff000000,
    endCap: Cap.ButtCap,
    geodesic: false,
    jointType: JointType.Default,
    pattern: <Pattern>[],
    startCap: Cap.ButtCap,
    visible: true,
    width: 10,
    zIndex: 0.0,
  );

  /// Creates a new options object whose values are the same as this instance,
  /// unless overwritten by the specified [changes].
  ///
  /// Returns this instance, if [changes] is null.
  PolylineOptions copyWith(PolylineOptions changes) {
    if (changes == null) {
      return this;
    }
    return PolylineOptions(
      points: changes.points ?? points,
      clickable: changes.clickable ?? clickable,
      color: changes.color ?? color,
      endCap: changes.endCap ?? endCap,
      geodesic: changes.geodesic ?? geodesic,
      jointType: changes.jointType ?? jointType,
      pattern: changes.pattern ?? pattern,
      startCap: changes.startCap ?? startCap,
      visible: changes.visible ?? visible,
      width: changes.width ?? width,
      zIndex: changes.zIndex ?? zIndex,
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
}
