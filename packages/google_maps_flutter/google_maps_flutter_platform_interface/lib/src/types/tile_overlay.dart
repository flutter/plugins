// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart' show immutable;

import 'types.dart';

/// Uniquely identifies a [TileOverlay] among [GoogleMap] tile overlays.
@immutable
class TileOverlayId extends MapsObjectId<TileOverlay> {
  /// Creates an immutable identifier for a [TileOverlay].
  const TileOverlayId(String value) : super(value);
}

/// A set of images which are displayed on top of the base map tiles.
///
/// These tiles may be transparent, allowing you to add features to existing maps.
///
/// ## Tile Coordinates
///
/// Note that the world is projected using the Mercator projection
/// (see [Wikipedia](https://en.wikipedia.org/wiki/Mercator_projection)) with the left (west) side
/// of the map corresponding to -180 degrees of longitude and the right (east) side of the map
/// corresponding to 180 degrees of longitude. To make the map square, the top (north) side of the
/// map corresponds to 85.0511 degrees of latitude and the bottom (south) side of the map
/// corresponds to -85.0511 degrees of latitude. Areas outside this latitude range are not rendered.
///
/// At each zoom level, the map is divided into tiles and only the tiles that overlap the screen are
/// downloaded and rendered. Each tile is square and the map is divided into tiles as follows:
///
/// * At zoom level 0, one tile represents the entire world. The coordinates of that tile are
/// (x, y) = (0, 0).
/// * At zoom level 1, the world is divided into 4 tiles arranged in a 2 x 2 grid.
/// * ...
/// * At zoom level N, the world is divided into 4N tiles arranged in a 2N x 2N grid.
///
/// Note that the minimum zoom level that the camera supports (which can depend on various factors)
/// is GoogleMap.getMinZoomLevel and the maximum zoom level is GoogleMap.getMaxZoomLevel.
///
/// The coordinates of the tiles are measured from the top left (northwest) corner of the map.
/// At zoom level N, the x values of the tile coordinates range from 0 to 2N - 1 and increase from
/// west to east and the y values range from 0 to 2N - 1 and increase from north to south.
@immutable
class TileOverlay implements MapsObject<TileOverlay> {
  /// Creates an immutable representation of a [TileOverlay] to draw on [GoogleMap].
  const TileOverlay({
    required this.tileOverlayId,
    this.fadeIn = true,
    this.tileProvider,
    this.transparency = 0.0,
    this.zIndex = 0,
    this.visible = true,
    this.tileSize = 256,
  }) : assert(transparency >= 0.0 && transparency <= 1.0);

  /// Uniquely identifies a [TileOverlay].
  final TileOverlayId tileOverlayId;

  @override
  TileOverlayId get mapsId => tileOverlayId;

  /// Whether the tiles should fade in. The default is true.
  final bool fadeIn;

  /// The tile provider to use for this tile overlay.
  final TileProvider? tileProvider;

  /// The transparency of the tile overlay. The default transparency is 0 (opaque).
  final double transparency;

  /// The tile overlay's zIndex, i.e., the order in which it will be drawn where
  /// overlays with larger values are drawn above those with lower values
  final int zIndex;

  /// The visibility for the tile overlay. The default visibility is true.
  final bool visible;

  /// Specifies the number of logical pixels (not points) that the returned tile images will prefer
  /// to display as. iOS only.
  ///
  /// Defaults to 256, which is the traditional size of Google Maps tiles.
  /// As an example, an application developer may wish to provide retina tiles (512 pixel edge length)
  /// on retina devices, to keep the same number of tiles per view as the default value of 256
  /// would give on a non-retina device.
  final int tileSize;

  /// Creates a new [TileOverlay] object whose values are the same as this instance,
  /// unless overwritten by the specified parameters.
  TileOverlay copyWith({
    bool? fadeInParam,
    TileProvider? tileProviderParam,
    double? transparencyParam,
    int? zIndexParam,
    bool? visibleParam,
    int? tileSizeParam,
  }) {
    return TileOverlay(
      tileOverlayId: tileOverlayId,
      fadeIn: fadeInParam ?? fadeIn,
      tileProvider: tileProviderParam ?? tileProvider,
      transparency: transparencyParam ?? transparency,
      zIndex: zIndexParam ?? zIndex,
      visible: visibleParam ?? visible,
      tileSize: tileSizeParam ?? tileSize,
    );
  }

  @override
  TileOverlay clone() => copyWith();

  /// Converts this object to JSON.
  @override
  Object toJson() {
    final Map<String, Object> json = <String, Object>{};

    void addIfPresent(String fieldName, Object? value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('tileOverlayId', tileOverlayId.value);
    addIfPresent('fadeIn', fadeIn);
    addIfPresent('transparency', transparency);
    addIfPresent('zIndex', zIndex);
    addIfPresent('visible', visible);
    addIfPresent('tileSize', tileSize);

    return json;
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is TileOverlay &&
        tileOverlayId == other.tileOverlayId &&
        fadeIn == other.fadeIn &&
        tileProvider == other.tileProvider &&
        transparency == other.transparency &&
        zIndex == other.zIndex &&
        visible == other.visible &&
        tileSize == other.tileSize;
  }

  @override
  int get hashCode => Object.hash(tileOverlayId, fadeIn, tileProvider,
      transparency, zIndex, visible, tileSize);
}
