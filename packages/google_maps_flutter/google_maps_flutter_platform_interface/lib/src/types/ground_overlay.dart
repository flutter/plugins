// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' show hashValues;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart' show immutable;

import 'types.dart';

/// Uniquely identifies a [GroundOverlay] among [GoogleMap] ground overlays.
@immutable
class GroundOverlayId extends MapsObjectId<GroundOverlay> {
  /// Creates an immutable identifier for a [GroundOverlay].
  const GroundOverlayId(String value) : super(value);
}

/// An image overlays that is tied to latitude/longitude coordinates, so it
/// moves when you drag or zoom the map.
///
/// A ground overlay is an image that is fixed to a map. Unlike markers, ground
/// overlays are oriented against the Earth's surface rather than the screen,
/// so rotating, tilting or zooming the map will change the orientation of the
/// image. Ground overlays are useful when you wish to fix a single image at one
/// area on the map. If you want to add extensive imagery that covers a large
/// portion of the map, you should consider a Tile overlay.
///
class GroundOverlay implements MapsObject {
  /// Creates an immutable representation of a [GroundOverlay] to draw on
  /// [GoogleMap].
  const GroundOverlay({
    required this.groundOverlayId,
    required this.image,
    this.anchorU,
    this.anchorV,
    this.bearing = 0,
    this.isClickable = false,
    this.position,
    this.width,
    this.height,
    this.positionFromBounds,
    this.transparency = 0,
    this.isVisible = true,
    this.zIndex = 0,
  }) : assert(((height == null &&
                    width == null &&
                    position == null &&
                    positionFromBounds != null) ||
                (height != null &&
                    width != null &&
                    position != null &&
                    positionFromBounds == null) ||
                (height == null &&
                    width != null &&
                    position != null &&
                    positionFromBounds == null)) &&
            (transparency >= 0.0 && transparency <= 1.0) &&
            (anchorU == null || (anchorU >= 0.0 && anchorU <= 1.0)) &&
            (anchorV == null || (anchorV >= 0.0 && anchorV <= 1.0)));

  @override
  MapsObjectId get mapsId => groundOverlayId;

  /// Uniquely identifies a [GroundOverlay].
  final GroundOverlayId groundOverlayId;

  /// Specifies the image for this ground overlay.
  final BitmapDescriptor image;

  /// Specifies u-coordinate of the anchor.
  final double? anchorU;

  /// Specifies v-coordinate of the anchor.
  final double? anchorV;

  /// Specifies the bearing of the ground overlay in degrees clockwise from
  /// north.
  final double bearing;

  /// Specifies whether the ground overlay is clickable.
  final bool isClickable;

  /// The location on the map LatLng to which the anchor point in the given
  /// image will remain fixed. The anchor will remain fixed to the position on
  /// the ground when transformations are applied (e.g., setDimensions,
  /// setBearing, etc.). At least [width] must be specified along with this
  /// parameter. The image will be scaled to fit the dimensions specified.
  final LatLng? position;

  /// The width of the overlay (in meters). Must be provided along with the
  /// [position]. The [height], if not specified, will be determined
  /// automatically based on the image aspect ratio if not specified.
  ///
  /// [width] and [height] can not be updated once a [GroundOverlay] is created
  /// and added to the map. In order to have the changes to [width] and [height]
  /// take effect, existing [GroundOverlay] must be removed first.
  final double? width;

  /// The height of the overlay (in meters). May be provided along with the
  /// [position]. If not specified, it'll will be determined automatically based
  /// on the image aspect ratio.
  ///
  /// [width] and [height] can not be updated once a [GroundOverlay] is created
  /// and added to the map. In order to have the changes to [width] and [height]
  /// take effect, existing [GroundOverlay] must be removed first.
  final double? height;

  /// Specifies the position for this ground overlay.
  final LatLngBounds? positionFromBounds;

  /// Specifies the transparency of the ground overlay.
  final double transparency;

  /// Specifies the visibility for the ground overlay.
  final bool isVisible;

  /// Specifies the ground overlay's zIndex, i.e., the order in which it will be
  /// drawn.
  final double zIndex;

  /// Creates a new [GroundOverlay] object whose values are the same as this
  /// instance, unless overwritten by the specified parameters.
  GroundOverlay copyWith({
    GroundOverlayId? groundOverlayIdParam,
    BitmapDescriptor? imageParam,
    double? anchorUParam,
    double? anchorVParam,
    double? bearingParam,
    bool? isClickableParam,
    LatLng? positionParam,
    double? widthParam,
    double? heightParam,
    LatLngBounds? positionFromBoundsParam,
    double? transparencyParam,
    bool? isVisibleParam,
    double? zIndexParam,
  }) {
    return GroundOverlay(
      groundOverlayId: groundOverlayIdParam ?? groundOverlayId,
      image: imageParam ?? image,
      anchorU: anchorUParam ?? anchorU,
      anchorV: anchorVParam ?? anchorV,
      bearing: bearingParam ?? bearing,
      isClickable: isClickableParam ?? isClickable,
      position: positionParam ?? position,
      width: widthParam ?? width,
      height: heightParam ?? height,
      positionFromBounds: positionFromBoundsParam ?? positionFromBounds,
      transparency: transparencyParam ?? transparency,
      isVisible: isVisibleParam ?? isVisible,
      zIndex: zIndexParam ?? zIndex,
    );
  }

  @override
  clone() => copyWith();

  @override
  Object toJson() {
    final Map<String, Object> json = <String, Object>{};

    void addIfPresent(String fieldName, Object? value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent("groundOverlayId", groundOverlayId.value);
    addIfPresent("image", image.toJson());
    addIfPresent("anchorU", anchorU);
    addIfPresent("anchorV", anchorV);
    addIfPresent("bearing", bearing);
    addIfPresent("isClickable", isClickable);
    addIfPresent("position", position?.toJson());
    addIfPresent("width", width);
    addIfPresent("height", height);
    addIfPresent("positionFromBounds", positionFromBounds?.toJson());
    addIfPresent("transparency", transparency);
    addIfPresent("isVisible", isVisible);
    addIfPresent("zIndex", zIndex);

    return json;
  }

  @override
  bool operator ==(Object other) {
    if (other is! GroundOverlay) {
      return false;
    }
    bool isImageSame = false;
    if (image != null && other.image != null) {
      List<dynamic> thisImage = image.toJson() as List<dynamic>;
      List<dynamic> otherImage = other.image.toJson() as List<dynamic>;
      isImageSame = ListEquality().equals(thisImage, otherImage);
    } else {
      return false;
    }
    return groundOverlayId == other.groundOverlayId &&
        isImageSame &&
        anchorU == other.anchorU &&
        anchorV == other.anchorV &&
        bearing == other.bearing &&
        isClickable == other.isClickable &&
        position == other.position &&
        width == other.width &&
        height == other.height &&
        positionFromBounds == other.positionFromBounds &&
        transparency == other.transparency &&
        isVisible == other.isVisible &&
        zIndex == other.zIndex;
  }

  @override
  int get hashCode => hashValues(
      groundOverlayId,
      image,
      anchorU,
      anchorV,
      bearing,
      isClickable,
      position,
      width,
      height,
      positionFromBounds,
      transparency,
      isVisible,
      zIndex);
}
