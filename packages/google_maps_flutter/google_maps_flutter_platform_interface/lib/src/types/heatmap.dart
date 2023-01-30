// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart'
    show listEquals, objectRuntimeType, immutable;
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
    this.opacity = 0.7,
    this.radius = 20,
    this.minimumZoomIntensity = 0,
    this.maximumZoomIntensity = 21,
  }) : assert(opacity >= 0 && opacity <= 1);

  /// Uniquely identifies a [Heatmap].
  final HeatmapId heatmapId;

  @override
  HeatmapId get mapsId => heatmapId;

  /// The data points to display.
  final List<WeightedLatLng> data;

  /// Specifies whether heatmaps dissipate on zoom.
  ///
  /// By default, the radius of influence of a data point is specified by the
  /// radius option only. When dissipating is disabled, the radius option is
  /// interpreted as a radius at zoom level 0.
  final bool dissipating;

  /// The color gradient of the heatmap
  final HeatmapGradient? gradient;

  /// The maximum intensity of the heatmap.
  ///
  /// By default, heatmap colors are dynamically scaled according to the
  /// greatest concentration of points at any particular pixel on the map.
  /// This property allows you to specify a fixed maximum.
  final double? maxIntensity;

  /// The opacity of the heatmap, expressed as a number between 0 and 1.
  final double opacity;

  /// The radius of influence for each data point, in pixels.
  final int radius;

  /// The minimum zoom intensity used for normalizing intensities.
  final int minimumZoomIntensity;

  /// The maximum zoom intensity used for normalizing intensities.
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

/// A data point entry for a heatmap.
///
/// This is a geographical data point with a weight attribute.
@immutable
class WeightedLatLng {
  /// Creates a [WeightedLatLng] with the specified [weight]
  const WeightedLatLng(this.point, {this.weight = 1.0});

  /// The geographical data point.
  final LatLng point;

  /// The weighting value of the data point.
  final double weight;

  /// Converts this object to something serializable in JSON.
  Object toJson() {
    return <Object>[point.toJson(), weight];
  }

  @override
  String toString() {
    return '${objectRuntimeType(this, 'WeightedLatLng')}($point, $weight)';
  }

  @override
  bool operator ==(Object other) {
    return other is WeightedLatLng &&
        other.point == point &&
        other.weight == weight;
  }

  @override
  int get hashCode => Object.hash(point, weight);
}

/// Represents a mapping of intensity to color.
///
/// Interpolates between given set of intensity and color values to produce a
/// full mapping for the range [0, 1].
@immutable
class HeatmapGradient {
  /// Creates a new [HeatmapGradient] object.
  const HeatmapGradient(
    this.colors, {
    this.colorMapSize = 256,
  }) : assert(colors.length > 0);

  /// The gradient colors.
  ///
  /// Distributed along [startPoint]s or uniformly depending on the platform.
  final List<HeatmapGradientColor> colors;

  /// Number of entries in the generated color map.
  final int colorMapSize;

  /// Creates a new [HeatmapGradient] object whose values are the same as this
  /// instance, unless overwritten by the specified parameters.
  HeatmapGradient copyWith({
    List<HeatmapGradientColor>? colorsParam,
    int? colorMapSizeParam,
  }) {
    return HeatmapGradient(
      colorsParam ?? colors,
      colorMapSize: colorMapSizeParam ?? colorMapSize,
    );
  }

  /// Creates a new [HeatmapGradient] object whose values are the same as this
  /// instance.
  HeatmapGradient clone() => copyWith(
        colorsParam: List<HeatmapGradientColor>.of(colors),
      );

  /// Converts this object to something serializable in JSON.
  Object toJson() {
    final Map<String, Object> json = <String, Object>{};

    void addIfPresent(String fieldName, Object? value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('colors',
        colors.map((HeatmapGradientColor e) => e.color.value).toList());
    addIfPresent('startPoints',
        colors.map((HeatmapGradientColor e) => e.startPoint).toList());
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
        colorMapSize == other.colorMapSize;
  }

  @override
  int get hashCode => Object.hash(colors, colorMapSize);
}

/// A [Color] with a [startPoint] for use in a [HeatmapGradient].
@immutable
class HeatmapGradientColor {
  /// Creates a new [HeatmapGradientColor] object.
  const HeatmapGradientColor(this.color, this.startPoint);

  /// The color for this portion of the gradient.
  final Color color;

  /// The start point of this color.
  final double startPoint;

  /// Creates a new [HeatmapGradientColor] object whose values are the same as
  /// this instance, unless overwritten by the specified parameters.
  HeatmapGradientColor copyWith({
    Color? colorParam,
    double? startPointParam,
  }) {
    return HeatmapGradientColor(
      colorParam ?? color,
      startPointParam ?? startPoint,
    );
  }

  /// Creates a new [HeatmapGradientColor] object whose values are the same as
  /// this instance.
  HeatmapGradientColor clone() => copyWith();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is HeatmapGradientColor &&
        color == other.color &&
        startPoint == other.startPoint;
  }

  @override
  int get hashCode => Object.hash(color, startPoint);

  @override
  String toString() {
    return '${objectRuntimeType(this, 'HeatmapGradientColor')}($color, $startPoint)';
  }
}
