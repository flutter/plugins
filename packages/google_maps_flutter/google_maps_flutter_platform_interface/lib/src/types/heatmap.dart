// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/material.dart' show Color;

import 'types.dart';

/// Uniquely identifies a [Heatmap] among [GoogleMap] heatmaps.
///
/// This does not have to be globally unique, only unique among the list.
@immutable
class HeatmapId extends MapsObjectId<Heatmap> {
  /// Creates an immutable identifier for a [Heatmap].
  const HeatmapId(String value) : super(value);
}

/// Draws a heatmap on the map.
@immutable
class Heatmap implements MapsObject<Heatmap> {
  /// Creates an immutable representation of a [Heatmap] to draw on
  /// [GoogleMap].
  const Heatmap({
    required this.heatmapId,
    this.data = const <WeightedLatLng>[],
    this.dissipating = true,
    this.gradient,
    this.maxIntensity,
    // Default is 0.6 on web, 0.7 on Android and iOS.
    this.opacity = 0.7,
    this.radius = 20,
    this.minimumZoomIntensity = 0,
    this.maximumZoomIntensity = 21,
  }) : // Docs for iOS say [radius] must be between 10 and 50, but anything
        // higher than 45 causes EXC_BAD_ACCESS.
        assert(radius >= 10 && radius <= 45);

  /// Uniquely identifies a [Heatmap].
  final HeatmapId heatmapId;

  @override
  HeatmapId get mapsId => heatmapId;

  /// The data points to display.
  final List<WeightedLatLng> data;

  /// Specifies whether heatmaps dissipate on zoom. By default, the radius of
  /// influence of a data point is specified by the radius option only. When
  /// dissipating is disabled, the radius option is interpreted as a radius at
  /// zoom level 0.
  ///
  /// Web only.
  final bool dissipating;

  /// The color gradient of the heatmap
  final HeatmapGradient? gradient;

  /// The maximum intensity of the heatmap. By default, heatmap colors are
  /// dynamically scaled according to the greatest concentration of points at
  /// any particular pixel on the map. This property allows you to specify a
  /// fixed maximum.
  ///
  /// Web and Android only.
  final double? maxIntensity;

  /// The opacity of the heatmap, expressed as a number between 0 and 1.
  final double opacity;

  /// The radius of influence for each data point, in pixels.
  final int radius;

  /// The minimum zoom intensity used for normalizing intensities.
  ///
  /// iOS only.
  final int minimumZoomIntensity;

  /// The maximum zoom intensity used for normalizing intensities.
  ///
  /// iOS only.
  final int maximumZoomIntensity;

  /// Creates a new [Heatmap] object whose values are the same as this
  /// instance, unless overwritten by the specified parameters.
  Heatmap copyWith({
    List<WeightedLatLng>? dataParam,
    bool? dissipatingParam,
    HeatmapGradient? gradientParam,
    double? maxIntensityParam,
    double? opacityParam,
    int? radiusParam,
    int? minimumZoomIntensityParam,
    int? maximumZoomIntensityParam,
  }) {
    return Heatmap(
      heatmapId: heatmapId,
      data: dataParam ?? data,
      dissipating: dissipatingParam ?? dissipating,
      gradient: gradientParam ?? gradient,
      maxIntensity: maxIntensityParam ?? maxIntensity,
      opacity: opacityParam ?? opacity,
      radius: radiusParam ?? radius,
      minimumZoomIntensity: minimumZoomIntensityParam ?? minimumZoomIntensity,
      maximumZoomIntensity: maximumZoomIntensityParam ?? maximumZoomIntensity,
    );
  }

  /// Creates a new [Heatmap] object whose values are the same as this
  /// instance.
  @override
  Heatmap clone() => copyWith(
        dataParam: List<WeightedLatLng>.of(data),
        gradientParam: gradient?.clone(),
      );

  /// Converts this object to something serializable in JSON.
  @override
  Object toJson() {
    final Map<String, Object> json = <String, Object>{};

    void addIfPresent(String fieldName, Object? value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('heatmapId', heatmapId.value);
    addIfPresent('data', data.map((WeightedLatLng e) => e.toJson()).toList());
    addIfPresent('dissipating', dissipating);
    addIfPresent('gradient', gradient?.toJson());
    addIfPresent('maxIntensity', maxIntensity);
    addIfPresent('opacity', opacity);
    addIfPresent('radius', radius);
    addIfPresent('minimumZoomIntensity', minimumZoomIntensity);
    addIfPresent('maximumZoomIntensity', maximumZoomIntensity);

    return json;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is Heatmap &&
        heatmapId == other.heatmapId &&
        listEquals(data, other.data) &&
        dissipating == other.dissipating &&
        gradient == other.gradient &&
        maxIntensity == other.maxIntensity &&
        opacity == other.opacity &&
        radius == other.radius &&
        minimumZoomIntensity == other.minimumZoomIntensity &&
        maximumZoomIntensity == other.maximumZoomIntensity;
  }

  @override
  int get hashCode => heatmapId.hashCode;
}

/// Represents a mapping of intensity to color.  Interpolates between given set
/// intensity and color values to produce a full mapping for the range [0, 1].
@immutable
class HeatmapGradient {
  /// Creates a new [HeatmapGradient] object.
  const HeatmapGradient({
    required this.colors,
    required this.startPoints,
    this.colorMapSize = 256,
  })  : assert(colors.length == startPoints.length),
        assert(colors.length > 0),
        assert(startPoints.length > 0);

  /// The specific colors for the specific intensities specified by startPoints.
  final List<Color> colors;

  /// The intensities which will be the specific colors specified in colors.
  ///
  /// Android and iOS only.
  final List<double> startPoints;

  /// Number of entries in the generated color map.
  ///
  /// Android and iOS only.
  final int colorMapSize;

  /// Creates a new [HeatmapGradient] object whose values are the same as this
  /// instance, unless overwritten by the specified parameters.
  HeatmapGradient copyWith({
    List<Color>? colorsParam,
    List<double>? startPointsParam,
    int? colorMapSizeParam,
  }) {
    return HeatmapGradient(
      colors: colorsParam ?? colors,
      startPoints: startPointsParam ?? startPoints,
      colorMapSize: colorMapSizeParam ?? colorMapSize,
    );
  }

  /// Creates a new [HeatmapGradient] object whose values are the same as this
  /// instance.
  HeatmapGradient clone() => copyWith(
        colorsParam: List<Color>.of(colors),
        startPointsParam: List<double>.of(startPoints),
      );

  /// Converts this object to something serializable in JSON.
  Object toJson() {
    final Map<String, Object> json = <String, Object>{};

    void addIfPresent(String fieldName, Object? value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('colors', colors.map((Color e) => e.value).toList());
    addIfPresent('startPoints', startPoints);
    addIfPresent('colorMapSize', colorMapSize);

    return json;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is HeatmapGradient &&
        listEquals(colors, other.colors) &&
        listEquals(startPoints, other.startPoints) &&
        colorMapSize == other.colorMapSize;
  }

  @override
  int get hashCode => Object.hash(colors, startPoints, colorMapSize);
}
