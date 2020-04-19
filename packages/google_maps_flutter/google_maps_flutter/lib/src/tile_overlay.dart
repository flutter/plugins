part of google_maps_flutter;

/// A Tile Overlay is a set of images which are displayed on top 
/// of the base map tiles. These tiles may be transparent, allowing 
/// you to add features to existing maps.
class TileOverlay {
  /// The width of the tile in pixels.
  final int width;

  /// The height of the tile in pixels.
  final int height;

  /// The url from where to fetch the tiles.
  ///
  /// The x, y, and z fields must surrounded by curly braces.
  /// For example: tiles.provider.com/{x}/{y}/{z}.png
  final String url;

  /// Whether the overlay tiles should fade in.
  final bool fadeIn;

  /// Indicates if the tile overlay is visible or invisible, i.e., whether it is drawn
  /// on the map. An invisible tile overlay is not drawn, but retains all of its other properties.
  /// The default is true, i.e., visible.
  final bool isVisible;

  /// Transparency of the tile overlay in the range [0..1] where 0 means the overlay
  /// is opaque and 1 means the overlay is fully transparent. If the specified bitmap
  /// is already partially transparent, the transparency of each pixel will be scaled
  /// accordingly (for example, if a pixel in the bitmap has an alpha value of 200 and
  /// you specify the transparency of the tile overlay as 0.25, then the pixel will be
  /// rendered on the screen with an alpha value of 150). Specification of this property
  /// is optional and the default transparency is 0 (opaque).
  final double transparency;

  /// The order in which this tile overlay is drawn with respect to other overlays
  /// (including GroundOverlays, Circles, Polylines, and Polygons but not Markers).
  /// An overlay with a larger z-index is drawn over overlays with smaller z-indices.
  /// The order of overlays with the same z-index is arbitrary. The default zIndex is 0.
  final double zIndex;

  /// Creates a [TileOverlay].
  /// 
  /// All values must not be null.
  const TileOverlay(
    this.width,
    this.height,
    this.url, {
    this.fadeIn = true,
    this.isVisible = true,
    this.transparency = 0.0,
    this.zIndex = 0.0,
  })  : assert(width != null),
        assert(height != null),
        assert(url != null),
        assert(fadeIn != null),
        assert(isVisible != null),
        assert(transparency != null && transparency >= 0.0),
        assert(zIndex != null && zIndex >= 0.0);

  Map<String, dynamic> _toMap() {
    return {
      'width': width,
      'height': height,
      'url': url,
      'fadeIn': fadeIn,
      'isVisible': isVisible,
      'transparency': transparency,
      'zIndex': zIndex,
    };
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is TileOverlay &&
        o.width == width &&
        o.height == height &&
        o.url == url &&
        o.fadeIn == fadeIn &&
        o.isVisible == isVisible &&
        o.transparency == transparency &&
        o.zIndex == zIndex;
  }

  @override
  int get hashCode {
    return width.hashCode ^
        height.hashCode ^
        url.hashCode ^
        fadeIn.hashCode ^
        isVisible.hashCode ^
        transparency.hashCode ^
        zIndex.hashCode;
  }

  @override
  String toString() {
    return 'TileOverlay(width: $width, height: $height, url: $url, fadeIn: $fadeIn, isVisible: $isVisible, transparency: $transparency, zIndex: $zIndex)';
  }
}

List<Map<String, dynamic>> _serializeTileOverlays(List<TileOverlay> overlays) {
  if (overlays == null) {
    return null;
  }

  return overlays.map<Map<String, dynamic>>((e) => e._toMap()).toList();
}
