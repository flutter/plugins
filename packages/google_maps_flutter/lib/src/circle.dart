// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter;

/// Uniquely identifies a [Circle] among [GoogleMap] circles.
///
/// This does not have to be globally unique, only unique among the list.
@immutable
class CircleId {
  CircleId(this.value) : assert(value != null);

  /// value of the [CircleId].
  final String value;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final CircleId typedOther = other;
    return value == typedOther.value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return 'CircleId{value: $value}';
  }
}

/// Draws a circle on the map.
@immutable
class Circle {
  const Circle({
    @required this.circleId,
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
  final VoidCallback onTap;

  /// Creates a new [Circle] object whose values are the same as this instance,
  /// unless overwritten by the specified parameters.
  Circle copyWith({
    bool consumeTapEventsParam,
    Color fillColorParam,
    LatLng centerParam,
    double radiusParam,
    Color strokeColorParam,
    int strokeWidthParam,
    bool visibleParam,
    int zIndexParam,
    VoidCallback onTapParam,
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

  dynamic _toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};

    void addIfPresent(String fieldName, dynamic value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('circleId', circleId.value);
    addIfPresent('consumeTapEvents', consumeTapEvents);
    addIfPresent('fillColor', fillColor.value);
    addIfPresent('center', center._toJson());
    addIfPresent('radius', radius);
    addIfPresent('strokeColor', strokeColor.value);
    addIfPresent('strokeWidth', strokeWidth);
    addIfPresent('visible', visible);
    addIfPresent('zIndex', zIndex);

    return json;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final Circle typedOther = other;
    return circleId == typedOther.circleId &&
        consumeTapEvents == typedOther.consumeTapEvents &&
        fillColor == typedOther.fillColor &&
        center == typedOther.center &&
        radius == typedOther.radius &&
        strokeColor == typedOther.strokeColor &&
        strokeWidth == typedOther.strokeWidth &&
        visible == typedOther.visible &&
        zIndex == typedOther.zIndex &&
        onTap == typedOther.onTap;
  }

  @override
  int get hashCode => circleId.hashCode;
}

Map<CircleId, Circle> _keyByCircleId(Iterable<Circle> circles) {
  if (circles == null) {
    return <CircleId, Circle>{};
  }
  return Map<CircleId, Circle>.fromEntries(circles.map(
      (Circle circle) => MapEntry<CircleId, Circle>(circle.circleId, circle)));
}

List<Map<String, dynamic>> _serializeCircleSet(Set<Circle> circles) {
  if (circles == null) {
    return null;
  }
  return circles.map<Map<String, dynamic>>((Circle p) => p._toJson()).toList();
}
