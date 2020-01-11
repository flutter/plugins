// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter;

/// Uniquely identifies a [Heatmap] among [GoogleMap] heatmaps.
///
/// This does not have to be globally unique, only unique among the list.
@immutable
class HeatmapId {
  /// Creates an immutable object representing a [HeatmapId] among [GoogleMap] heatmaps.
  ///
  /// An [AssertionError] will be thrown if [value] is null.
  HeatmapId(this.value) : assert(value != null);

  /// value of the [HeatmapId].
  final String value;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final HeatmapId typedOther = other;
    return value == typedOther.value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return 'HeatmapId{value: $value}';
  }
}

/// A pair of latitude and longitude coordinates, stored as degrees with a given intensity.
@immutable
class WeightedLatLng {
  /// Creates an immutable object representing a [WeightedLatLng].
  WeightedLatLng({
    @required this.point,
    this.intensity = 1,
  });

  /// The location of the [WeightedLatLng].
  final LatLng point;

  /// The intensity of the [WeightedLatLng].
  final int intensity;

  dynamic _toJson() {
    return <dynamic>[point._toJson(), intensity];
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final WeightedLatLng typedOther = other;
    return point == typedOther.point && intensity == typedOther.intensity;
  }

  @override
  int get hashCode => hashValues(point, intensity);

  @override
  String toString() {
    return 'WeightedLatLng{point: ${point.toString()}, intensity: $intensity}';
  }
}

/// An immutable gradient consisting of the given colors.
@immutable
class HeatmapGradient {
  /// Creates an immutable object representing a [HeatmapGradient]
  HeatmapGradient({
    @required this.colors,
    @required this.startPoints,
    this.colorMapSize = 256,
  });

  /// The colors to be used in the gradient
  final List<Color> colors;

  /// The starting point for each color, given as a percentage of the maximum intensity
  final List<double> startPoints;

  /// Size of a color map for the heatmap.
  final int colorMapSize;

  dynamic _toJson() {
    return <dynamic>[
      colors.map((Color c) => c.value).toList(),
      startPoints,
      colorMapSize
    ];
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final HeatmapGradient typedOther = other;
    return listEquals(colors, typedOther.colors) &&
        listEquals(startPoints, typedOther.startPoints) &&
        colorMapSize == typedOther.colorMapSize;
  }

  @override
  int get hashCode => hashValues(colors, startPoints, colorMapSize);

  @override
  String toString() {
    return 'HeatmapGradient{colors: ${colors.toString()}, startPoints: ${startPoints.toString()}, colorMapSize: ${colorMapSize.toString()}}';
  }
}

/// Paints a heatmap on geographical locations on the map.
@immutable
class Heatmap {
  /// Creates an immutable object representing a heatmap on the map.
  const Heatmap({
    @required this.heatmapId,
    this.points = const <WeightedLatLng>[],
    this.gradient,
    this.opacity = 0.7,
    this.radius = 20,
    this.fadeIn = true,
    this.transparency = 0,
    this.visible = true,
    this.zIndex = 0,
  });

  /// Uniquely identifies a [Heatmap].
  final HeatmapId heatmapId;

  /// The vertices of the heatmap to be painted.
  final List<WeightedLatLng> points;

  /// The gradient of the heatmap points.
  final HeatmapGradient gradient;

  /// The opacity of the heatmap points.
  final double opacity;

  /// The radius of the points in pixels, between 10 and 50.
  final int radius;

  /// Whether the heatmap layer should fade in.
  final bool fadeIn;

  /// The transparency of the heatmap layer.
  final double transparency;

  /// True if the marker is visible.
  final bool visible;

  /// The z-index of the polyline, used to determine relative drawing order of
  /// map overlays.
  ///
  /// Overlays are drawn in order of z-index, so that lower values means drawn
  /// earlier, and thus appearing to be closer to the surface of the Earth.
  final int zIndex;

  /// Creates a new [Heatmap] object whose values are the same as this instance,
  /// unless overwritten by the specified parameters.
  Heatmap copyWith({
    List<WeightedLatLng> pointsParam,
    HeatmapGradient gradientParam,
    double opacityParam,
    int radiusParam,
    bool fadeInParam,
    double transparencyParam,
    bool visibleParam,
    int zIndexParam,
  }) {
    return Heatmap(
      heatmapId: heatmapId,
      points: pointsParam ?? points,
      gradient: gradientParam ?? gradient,
      opacity: opacityParam ?? opacity,
      radius: radiusParam ?? radius,
      fadeIn: fadeInParam ?? fadeIn,
      transparency: transparencyParam ?? transparency,
      visible: visibleParam ?? visible,
      zIndex: zIndexParam ?? zIndex,
    );
  }

  /// Creates a new [Heatmap] object whose values are the same as this
  /// instance.
  Heatmap clone() {
    return copyWith(
      pointsParam: List<WeightedLatLng>.of(points),
    );
  }

  dynamic _toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};

    void addIfPresent(String fieldName, dynamic value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('heatmapId', heatmapId.value);
    addIfPresent('opacity', opacity);
    addIfPresent('radius', radius);
    addIfPresent('fadeIn', fadeIn);
    addIfPresent('transparency', transparency);
    addIfPresent('visible', visible);
    addIfPresent('zIndex', zIndex);

    if (gradient != null) {
      json['gradient'] = gradient._toJson();
    }

    if (points != null) {
      json['points'] = _pointsToJson();
    }

    return json;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final Heatmap typedOther = other;
    return heatmapId == typedOther.heatmapId &&
        listEquals(points, typedOther.points) &&
        gradient == typedOther.gradient &&
        opacity == typedOther.opacity &&
        radius == typedOther.radius &&
        fadeIn == typedOther.fadeIn &&
        transparency == typedOther.transparency &&
        visible == typedOther.visible &&
        zIndex == typedOther.zIndex;
  }

  @override
  int get hashCode => heatmapId.hashCode;

  dynamic _pointsToJson() {
    final List<dynamic> result = <dynamic>[];
    for (final WeightedLatLng point in points) {
      result.add(point._toJson());
    }
    return result;
  }
}

Map<HeatmapId, Heatmap> _keyByHeatmapId(Iterable<Heatmap> heatmaps) {
  if (heatmaps == null) {
    return <HeatmapId, Heatmap>{};
  }
  return Map<HeatmapId, Heatmap>.fromEntries(heatmaps.map((Heatmap heatmap) =>
      MapEntry<HeatmapId, Heatmap>(heatmap.heatmapId, heatmap.clone())));
}

List<Map<String, dynamic>> _serializeHeatmapSet(Set<Heatmap> heatmaps) {
  if (heatmaps == null) {
    return null;
  }
  return heatmaps
      .map<Map<String, dynamic>>((Heatmap p) => p._toJson())
      .toList();
}
