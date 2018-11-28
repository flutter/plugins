part of google_maps_flutter;

/// Immutable cap that can be applied at the start or end vertex of a Polyline.
class Cap {
  const Cap._(this._json);

  /// Cap that is squared off exactly at the start or end vertex of a Polyline
  /// with solid stroke pattern, equivalent to having no additional cap beyond
  /// the start or end vertex. This is the default cap type at start and end
  /// vertices of Polylines with solid stroke pattern.
  static const Cap buttCap = Cap._(<dynamic>['buttCap']);

  /// Cap that is a semicircle with radius equal to half the stroke width,
  /// centered at the start or end vertex of a Polyline with solid stroke
  /// pattern.
  static const Cap roundCap = Cap._(<dynamic>['roundCap']);

  /// Cap that is squared off after extending half the stroke width beyond the
  /// start or end vertex of a Polyline with solid stroke pattern.
  static const Cap squareCap = Cap._(<dynamic>['squareCap']);

  /// Constructs a new CustomCap with a bitmap overlay centered at the start or
  /// end vertex of a Polyline, orientated according to the direction of the line's
  /// first or last edge and scaled with respect to the line's stroke width. CustomCap
  /// can be applied to Polyline with any stroke pattern.
  ///
  /// [bitmapDescriptor] must not be null.
  /// [refWidth] is the reference stroke width (in pixels) - the stroke width for which
  /// the cap bitmap at its native dimension is designed. Must be positive.
  static Cap customCapFromBitmapRefWidth(
      BitmapDescriptor bitmapDescriptor, double refWidth) {
    assert(bitmapDescriptor != null);
    assert(refWidth > 0.0);
    return Cap._(<dynamic>['customCap', bitmapDescriptor._toJson(), refWidth]);
  }

  /// Constructs a new CustomCap with a Bitmap overlay.
  /// The default reference stroke width is 10 pixels.
  ///
  /// [bitmapDescriptor] must not be null.
  static Cap customCapFromBitmap(BitmapDescriptor bitmapDescriptor) {
    assert(bitmapDescriptor != null);
    return Cap._(<dynamic>['customCap', bitmapDescriptor._toJson()]);
  }

  final dynamic _json;

  dynamic _toJson() => _json;
}
