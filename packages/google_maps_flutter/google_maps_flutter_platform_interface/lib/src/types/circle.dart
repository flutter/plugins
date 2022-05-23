// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart' show VoidCallback;
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/material.dart' show Color, Colors;

import 'types.dart';

/// Uniquely identifies a [Circle] among [GoogleMap] circles.
///
/// This does not have to be globally unique, only unique among the list.
@immutable
class CircleId extends MapsObjectId<Circle> {
  /// Creates an immutable identifier for a [Circle].
  const CircleId(String value) : super(value);
}

/// Draws a circle on the map.
@immutable
class Circle implements MapsObject<Circle> {
  /// Creates an immutable representation of a [Circle] to draw on [GoogleMap].
  const Circle({
    required this.circleId,
    this.consumeTapEvents = false,
    this.fillColor = Colors.transparent,
    this.center = const LatLng(0.0, 0.0),
    this.radius = 0,
    this.strokeColor = Colors.black,
    this.strokeWidth = 10,
    this.visible = true,
    this.zIndex = 0,
    this.onTap,
  });

  /// Uniquely identifies a [Circle].
  final CircleId circleId;

  @override
  CircleId get mapsId => circleId;

  /// True if the [Circle] consumes tap events.
  ///
  /// If this is false, [onTap] callback will not be triggered.
  final bool consumeTapEvents;

  /// Fill color in ARGB format, the same format used by Color. The default value is transparent (0x00000000).
  final Color fillColor;

  /// Geographical location of the circle center.
  final LatLng center;

  /// Radius of the circle in meters; must be positive. The default value is 0.
  final double radius;

  /// Fill color in ARGB format, the same format used by Color. The default value is black (0xff000000).
  final Color strokeColor;

  /// The width of the circle's outline in screen points.
  ///
  /// The width is constant and independent of the camera's zoom level.
  /// The default value is 10.
  /// Setting strokeWidth to 0 results in no stroke.
  final int strokeWidth;

  /// True if the circle is visible.
  final bool visible;

  /// The z-index of the circle, used to determine relative drawing order of
  /// map overlays.
  ///
  /// Overlays are drawn in order of z-index, so that lower values means drawn
  /// earlier, and thus appearing to be closer to the surface of the Earth.
  final int zIndex;

  /// Callbacks to receive tap events for circle placed on this map.
  final VoidCallback? onTap;

  /// Creates a new [Circle] object whose values are the same as this instance,
  /// unless overwritten by the specified parameters.
  Circle copyWith({
    bool? consumeTapEventsParam,
    Color? fillColorParam,
    LatLng? centerParam,
    double? radiusParam,
    Color? strokeColorParam,
    int? strokeWidthParam,
    bool? visibleParam,
    int? zIndexParam,
    VoidCallback? onTapParam,
  }) {
    return Circle(
      circleId: circleId,
      consumeTapEvents: consumeTapEventsParam ?? consumeTapEvents,
      fillColor: fillColorParam ?? fillColor,
      center: centerParam ?? center,
      radius: radiusParam ?? radius,
      strokeColor: strokeColorParam ?? strokeColor,
      strokeWidth: strokeWidthParam ?? strokeWidth,
      visible: visibleParam ?? visible,
      zIndex: zIndexParam ?? zIndex,
      onTap: onTapParam ?? onTap,
    );
  }

  /// Creates a new [Circle] object whose values are the same as this instance.
  @override
  Circle clone() => copyWith();

  /// Converts this object to something serializable in JSON.
  @override
  Object toJson() {
    final Map<String, Object> json = <String, Object>{};

    void addIfPresent(String fieldName, Object? value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('circleId', circleId.value);
    addIfPresent('consumeTapEvents', consumeTapEvents);
    addIfPresent('fillColor', fillColor.value);
    addIfPresent('center', center.toJson());
    addIfPresent('radius', radius);
    addIfPresent('strokeColor', strokeColor.value);
    addIfPresent('strokeWidth', strokeWidth);
    addIfPresent('visible', visible);
    addIfPresent('zIndex', zIndex);

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
    return other is Circle &&
        circleId == other.circleId &&
        consumeTapEvents == other.consumeTapEvents &&
        fillColor == other.fillColor &&
        center == other.center &&
        radius == other.radius &&
        strokeColor == other.strokeColor &&
        strokeWidth == other.strokeWidth &&
        visible == other.visible &&
        zIndex == other.zIndex;
  }

  @override
  int get hashCode => circleId.hashCode;
}
