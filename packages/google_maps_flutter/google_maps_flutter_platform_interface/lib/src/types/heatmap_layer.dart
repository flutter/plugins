// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart' show Color;
import 'package:flutter/foundation.dart' show immutable;

import 'types.dart';

/// Uniquely identifies a [HeatmapLayer] among [GoogleMap] heatmap layers.
///
/// This does not have to be globally unique, only unique among the list.
@immutable
class HeatmapLayerId extends MapsObjectId<HeatmapLayer> {
  /// Creates an immutable identifier for a [HeatmapLayer].
  const HeatmapLayerId(String value) : super(value);
}

/// Draws a heatmap layer on the map.
@immutable
class HeatmapLayer implements MapsObject<HeatmapLayer> {
  /// Creates an immutable representation of a [HeatmapLayer] to draw on
  /// [GoogleMap].
  const HeatmapLayer({
    required this.heatmapLayerId,
    this.data = const [],
    this.dissipating = true,
    this.gradient,
    this.maxIntensity,
    this.opacity = 0.6,
    this.radius,
  });

  /// Uniquely identifies a [HeatmapLayer].
  final HeatmapLayerId heatmapLayerId;

  @override
  HeatmapLayerId get mapsId => heatmapLayerId;

  /// The data points to display.
  final List<WeightedLatLng> data;

  /// Specifies whether heatmaps dissipate on zoom. By default, the radius of
  /// influence of a data point is specified by the radius option only. When
  /// dissipating is disabled, the radius option is interpreted as a radius at
  /// zoom level 0.
  /// 
  /// TODO: Not on android
  final bool dissipating;

  /// The color gradient of the heatmap
  final List<Color>? gradient;

  /// The maximum intensity of the heatmap. By default, heatmap colors are
  /// dynamically scaled according to the greatest concentration of points at
  /// any particular pixel on the map. This property allows you to specify a
  /// fixed maximum.
  final double? maxIntensity;

  /// The opacity of the heatmap, expressed as a number between 0 and 1.
  /// Defaults to 0.6.
  final double opacity;

  /// The radius of influence for each data point, in pixels.
  final int? radius;

  /// Creates a new [HeatmapLayer] object whose values are the same as this
  /// instance, unless overwritten by the specified parameters.
  HeatmapLayer copyWith({
    List<WeightedLatLng>? dataParam,
    bool? dissipatingParam,
    List<Color>? gradientParam,
    double? maxIntensityParam,
    double? opacityParam,
    int? radiusParam,
  }) {
    return HeatmapLayer(
      heatmapLayerId: heatmapLayerId,
      data: dataParam ?? data,
      dissipating: dissipatingParam ?? dissipating,
      gradient: gradientParam ?? gradient,
      maxIntensity: maxIntensityParam ?? maxIntensity,
      opacity: opacityParam ?? opacity,
      radius: radiusParam ?? radius,
    );
  }

  /// Creates a new [HeatmapLayer] object whose values are the same as this
  /// instance.
  HeatmapLayer clone() => copyWith(
        dataParam: List.of(data),
        gradientParam: gradient != null ? List.of(gradient!) : null,
      );

  /// Converts this object to something serializable in JSON.
  Object toJson() {
    final Map<String, Object> json = <String, Object>{};

    void addIfPresent(String fieldName, Object? value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('heatmapLayerId', heatmapLayerId.value);
    addIfPresent('data', data.map((e) => e.toJson()));
    addIfPresent('dissipating', dissipating);
    addIfPresent('gradient', gradient?.map((e) => e.value));
    addIfPresent('maxIntensity', maxIntensity);
    addIfPresent('opacity', opacity);
    addIfPresent('radius', radius);

    return json;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final HeatmapLayer typedOther = other as HeatmapLayer;
    return heatmapLayerId == typedOther.heatmapLayerId &&
        listEquals(data, typedOther.data) &&
        dissipating == typedOther.dissipating &&
        listEquals(gradient, typedOther.gradient) &&
        maxIntensity == typedOther.maxIntensity &&
        opacity == typedOther.opacity &&
        radius == typedOther.radius;
  }

  @override
  int get hashCode => heatmapLayerId.hashCode;
}
