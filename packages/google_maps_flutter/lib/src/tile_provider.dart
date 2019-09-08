part of google_maps_flutter;

/// An interface for a class that provides the tile images for a TileOverlay.
abstract class TileProvider {
  /// Stub tile that is used to indicate that no tile exists for a specific tile coordinate.
  static const Tile noTile = Tile(-1, -1, null);

  /// Returns the tile to be used for this tile coordinate.
  Future<Tile> getTile(int x, int y, int zoom);
}
