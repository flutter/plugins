// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'types.dart';

/// An interface for a class that provides the tile images for a TileOverlay.
abstract class TileProvider {
  /// Stub tile that is used to indicate that no tile exists for a specific tile coordinate.
  static const Tile noTile = Tile(-1, -1, null);

  /// Returns the tile to be used for this tile coordinate.
  ///
  /// See [TileOverlay] for the specification of tile coordinates.
  Future<Tile> getTile(int x, int y, int? zoom);
}
