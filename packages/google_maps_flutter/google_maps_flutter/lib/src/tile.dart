part of google_maps_flutter;

/// Contains information about a Tile that is returned by a [TileProvider].
@immutable
class Tile {
  /// Creates an immutable representation of a [Tile] to draw by [TileProvider].
  const Tile(this.width, this.height, this.data);

  /// The width of the image encoded by data in pixels.
  final int width;

  /// The height of the image encoded by data in pixels.
  final int height;

  /// A byte array containing the image data.
  final Uint8List data;

  dynamic _toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};

    void addIfPresent(String fieldName, dynamic value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('width', width);
    addIfPresent('height', height);
    addIfPresent('data', data);

    return json;
  }
}
