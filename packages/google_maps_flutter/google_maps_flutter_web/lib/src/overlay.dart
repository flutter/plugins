// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter_web;

/// This wraps a [TileOverlay] in a [gmaps.MapType].
class TileOverlayController {
  /// For consistency with Android, this is not configurable.
  // TODO(AsturaPhoenix): Verify consistency with iOS.
  static const int logicalTileSize = 256;

  /// Updates the [gmaps.MapType] and cached properties with an updated
  /// [TileOverlay].
  void update(TileOverlay tileOverlay) {
    _tileOverlay = tileOverlay;
    _gmMapType = gmaps.MapType()
      ..tileSize = gmaps.Size(logicalTileSize, logicalTileSize)
      ..getTile = _getTile;
  }

  HtmlElement? _getTile(
      gmaps.Point? tileCoord, num? zoom, Document? ownerDocument) {
    if (_tileOverlay.tileProvider == null) {
      return null;
    }

    final ImageElement img =
        ownerDocument!.createElement('img') as ImageElement;
    img.width = img.height = logicalTileSize;
    img.hidden = true;
    _tileOverlay.tileProvider!
        .getTile(tileCoord!.x!.toInt(), tileCoord.y!.toInt(), zoom?.toInt())
        .then((Tile tile) async {
      if (tile.data == null) {
        return;
      }

      // Using img lets us take advantage of native decoding.
      final String src = Url.createObjectUrl(Blob(<dynamic>[tile.data]));
      // Spurious linter warning in legacy analyzer. (google/pedantic#83)
      // ignore: unsafe_html
      img.src = src;
      await img.decode();
      img.hidden = false;
      Url.revokeObjectUrl(src);
    });
    return img;
  }

  /// The [gmaps.MapType] produced by this controller.
  gmaps.MapType get gmMapType => _gmMapType;
  late gmaps.MapType _gmMapType;

  /// The [TileOverlay] providing data for this controller.
  TileOverlay get tileOverlay => _tileOverlay;
  late TileOverlay _tileOverlay;
}
