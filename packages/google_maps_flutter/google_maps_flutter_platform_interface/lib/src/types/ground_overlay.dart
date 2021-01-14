import 'dart:ui';

import 'package:flutter/foundation.dart' show VoidCallback;
import 'package:meta/meta.dart' show immutable, required;

import 'types.dart';

/// Uniquely identifies a [GroundOverlay] among [GoogleMap] ground overlays.
///
/// This does not have to be globally unique, only unique among the list.
@immutable
class GroundOverlayId {
  /// Creates an immutable identifier for a [GroundOverlay].
  GroundOverlayId(this.value) : assert(value != null);

  /// value of the [GroundOverlayId].
  final String value;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final GroundOverlayId typedOther = other;
    return value == typedOther.value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return 'GroundOverlayId{value: $value}';
  }
}

/// Draws a ground overlay on the map.
@immutable
class GroundOverlay {
  /// Creates an immutable representation of a [GroundOverlay] to draw on [GoogleMap].
  /// The following ground overlay positioning is allowed by the Google Maps Api
  /// 1. Using [height], [width] and [LatLng]
  /// 2. Using [width], [width]
  /// 3. Using [LatLngBounds]
  const GroundOverlay({
    @required this.groundOverlayId,
    this.consumeTapEvents = false,
    this.location,
    this.zIndex = 0,
    this.onTap,
    this.visible = true,
    this.bitmap,
    this.bounds,
    this.width,
    this.height,
    this.bearing,
    this.anchor,
    this.opacity = 1.0,
  }) : assert(
            (height != null &&
                    width != null &&
                    location != null &&
                    bounds == null) ||
                (height == null &&
                    width == null &&
                    location == null &&
                    bounds != null) ||
                (height == null &&
                    width != null &&
                    location != null &&
                    bounds == null) ||
                (height == null &&
                    width == null &&
                    location == null &&
                    bounds == null),
            "Only one of the three types of positioning is allowed, please refer "
            "to the https://developers.google.com/maps/documentation/android-sdk/groundoverlay#add_an_overlay"),assert(opacity == null ||
      (0.0 <= opacity && opacity <= 1.0));

  /// Creates an immutable representation of a [GroundOverlay] to draw on [GoogleMap]
  /// using [LatLngBounds]
  const GroundOverlay.fromBounds(
    this.bounds, {
    @required this.groundOverlayId,
    this.anchor,
    this.bearing = 0.0,
    this.bitmap,
    this.consumeTapEvents = false,
    this.onTap,
    this.opacity = 1.0,
    this.visible = true,
    this.zIndex = 0,
  })  : assert(opacity == null ||
            (0.0 <= opacity && opacity <= 1.0)),
        location = null,
        height = null,
        width = null;

  /// Uniquely identifies a [GroundOverlay].
  final GroundOverlayId groundOverlayId;

  /// True if the [GroundOverlay] consumes tap events.
  ///
  /// If this is false, [onTap] callback will not be triggered.
  final bool consumeTapEvents;

  /// Geographical location of the center of the ground overlay.
  final LatLng location;

  /// True if the ground overlay is visible.
  final bool visible;

  /// The z-index of the ground overlay, used to determine relative drawing order of
  /// map overlays.
  ///
  /// Overlays are drawn in order of z-index, so that lower values means drawn
  /// earlier, and thus appearing to be closer to the surface of the Earth.
  final int zIndex;

  /// Callbacks to receive tap events for ground overlay placed on this map.
  final VoidCallback onTap;

  /// A description of the bitmap used to draw the ground overlay image.
  final BitmapDescriptor bitmap;

  /// Width of the ground overlay in meters
  final double width;

  /// Height of the ground overlay in meters
  final double height;

  /// The amount that the image should be rotated in a clockwise direction.
  /// The center of the rotation will be the image's anchor.
  /// This is optional and the default bearing is 0, i.e., the image
  /// is aligned so that up is north.
  final double bearing;

  /// The anchor is, by default, 50% from the top of the image and 50% from the left of the image.
  final Offset anchor;

  /// Transparency of the ground overlay
  final double opacity;

  /// A latitude/longitude alignment of the ground overlay.
  final LatLngBounds bounds;

  /// Creates a new [GroundOverlay] object whose values are the same as this instance,
  /// unless overwritten by the specified parameters.
  GroundOverlay copyWith({
    BitmapDescriptor bitmapParam,
    Offset anchorParam,
    int zIndexParam,
    bool visibleParam,
    bool consumeTapEventsParam,
    double widthParam,
    double heightParam,
    double bearingParam,
    LatLng locationParam,
    LatLngBounds boundsParam,
    VoidCallback onTapParam,
    double opacityParam,
  }) {
    return GroundOverlay(
        groundOverlayId: groundOverlayId,
        consumeTapEvents: consumeTapEventsParam ?? consumeTapEvents,
        bitmap: bitmapParam ?? bitmap,
        opacity: opacityParam ?? opacity,
        location: locationParam ?? location,
        visible: visibleParam ?? visible,
        bearing: bearingParam ?? bearing,
        anchor: anchorParam ?? anchor,
        height: heightParam ?? height,
        bounds: boundsParam ?? bounds,
        zIndex: zIndexParam ?? zIndex,
        width: widthParam ?? width,
        onTap: onTapParam ?? onTap);
  }

  /// Creates a new [GroundOverlay] object whose values are the same as this instance.
  GroundOverlay clone() => copyWith();

  /// Converts this object to something serializable in JSON.
  dynamic toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};

    void addIfPresent(String fieldName, dynamic value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('groundOverlayId', groundOverlayId.value);
    addIfPresent('consumeTapEvents', consumeTapEvents);
    addIfPresent('transparency', 1 - opacity);
    addIfPresent('bearing', bearing);
    addIfPresent('visible', visible);
    addIfPresent('zIndex', zIndex);
    addIfPresent('height', height);
    addIfPresent('anchor', _offsetToJson(anchor));
    addIfPresent('bounds', bounds?.toJson());
    addIfPresent('bitmap', bitmap?.toJson());
    addIfPresent('width', width);
    if (location != null) {
      json['location'] = _locationToJson();
    }
    return json;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final GroundOverlay typedOther = other;
    return groundOverlayId == typedOther.groundOverlayId &&
        bitmap == typedOther.bitmap &&
        consumeTapEvents == typedOther.consumeTapEvents &&
        opacity == typedOther.opacity &&
        location == typedOther.location &&
        bearing == typedOther.bearing &&
        visible == typedOther.visible &&
        height == typedOther.height &&
        zIndex == typedOther.zIndex &&
        bounds == typedOther.bounds &&
        anchor == typedOther.anchor &&
        width == typedOther.width &&
        onTap == typedOther.onTap;
  }

  @override
  int get hashCode => groundOverlayId.hashCode;

  dynamic _locationToJson() => location.toJson();

  dynamic _offsetToJson(Offset offset) {
    if (offset == null) {
      return null;
    }
    return <dynamic>[offset.dx, offset.dy];
  }
}
