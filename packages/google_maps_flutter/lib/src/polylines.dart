part of google_maps_flutter;

enum Cap {
  /// Cap that is squared off exactly at the start or end vertex of a Polyline
  /// with solid stroke pattern, equivalent to having no additional cap beyond
  /// the start or end vertex.
  buttCap,

  /// Cap that is a semicircle with radius equal to half the stroke width,
  /// centered at the start or end vertex of a Polyline
  roundCap,

  /// Cap that is squared off after extending half the stroke width
  /// beyond the start or end vertex of a Polyline
  squareCap,
}

dynamic _capToJson(Cap cap) {
  if (cap == null)
    return null;
  switch (cap) {
    case Cap.buttCap:
      return <String>["buttCap"];
    case Cap.roundCap:
      return <String>["roundCap"];
    case Cap.squareCap:
      return <String>["squareCap"];
  }
  return null;
}

enum JointType {
  DEFAULT,
  BEVEL,
  ROUND,
}

dynamic _pointsToJson(List<LatLng> points) {
  if (points == null)
    return null;

  final List<dynamic> jsonData = <dynamic>[];

  for (int i = 0; i < points.length; ++i) {
    jsonData.add(points[i]._toJson());
  }

  return jsonData;
}

/// A polyline is a list of points, where line segments are drawn between
/// consecutive points.
/// Polylines are owned by a single [GoogleMapController] which fires events
/// as polylines are added, updated, tapped, and removed.
class Polyline {
  @visibleForTesting
  Polyline(this._id, this._options);

  final String _id;
  PolylineOptions _options;

  /// The marker configuration options most recently applied programmatically
  /// via the map controller.
  ///
  /// The returned value does not reflect any changes made to the marker through
  /// touch events. Add listeners to the owning map controller to track those.
  PolylineOptions get options => _options;
}

/// Configuration options for [Polyline] instances.
///
/// When used to change configuration, null values will be interpreted as
/// "do not change this configuration option".
class PolylineOptions {
  /// True if polyline is clickable
  final bool clickable;

  /// Line segment color in ARGB format
  final int color;

  final Cap endCap;

  final bool geodesic;

  final JointType jointType;

  // TODO: pattern

  final Cap startCap;

  final List<LatLng> points;

  /// True if the marker is visible.
  final bool visible;

  final double width;

  /// The z-index of the marker, used to determine relative drawing order of
  /// map overlays.
  ///
  /// Overlays are drawn in order of z-index, so that lower values means drawn
  /// earlier, and thus appearing to be closer to the surface of the Earth.
  final double zIndex;

  /// Creates a set of marker configuration options.
  ///
  /// By default, every non-specified field is null, meaning no desire to change
  /// marker defaults or current configuration.
  const PolylineOptions({
    this.clickable,
    this.color,
    this.endCap,
    this.geodesic,
    this.jointType,
    this.startCap,
    this.points,
    this.visible,
    this.width,
    this.zIndex,
  });

  /// Default polyline options.
  ///
  /// Specifies a marker that
  /// * is not clickable; [clickable] is false
  /// * is black in color; [color] is (0xFF000000)
  /// * has default endCap; [endCap] is [Cap.buttCap]
  /// * is drawn against the screen, not the map; [flat] is false
  /// * has a default icon; [icon] is `BitmapDescriptor.defaultMarker`
  /// * anchors the info window at top center; [infoWindowAnchor] is (0.5, 0.0)
  /// * has no info window text; [infoWindowText] is `InfoWindowText.noText`
  /// * is positioned at 0, 0; [position] is `LatLng(0.0, 0.0)`
  /// * has an axis-aligned icon; [rotation] is 0.0
  /// * is visible; [visible] is true
  /// * is placed at the base of the drawing order; [zIndex] is 0.0
  static const PolylineOptions defaultOptions = PolylineOptions(
    clickable: false,
    color: 0xFF000000,
    endCap: Cap.buttCap,
    geodesic: false,
    jointType: JointType.DEFAULT,
    startCap: Cap.buttCap,
    width: 10.0,
    visible: true,
    zIndex: 0.0,
  );

  /// Creates a new options object whose values are the same as this instance,
  /// unless overwritten by the specified [changes].
  ///
  /// Returns this instance, if [changes] is null.
  PolylineOptions copyWith(PolylineOptions changes) {
    if (changes == null) {
      return this;
    }
    return PolylineOptions(
      clickable: changes.clickable ?? clickable,
      color: changes.color ?? color,
      endCap: changes.endCap ?? endCap,
      geodesic: changes.geodesic ?? geodesic,
      jointType: changes.jointType ?? jointType,
      startCap: changes.startCap ?? startCap,
      width: changes.width ?? width,
      points: changes.points ?? points,
      visible: changes.visible ?? visible,
      zIndex: changes.zIndex ?? zIndex,
    );
  }

  dynamic _toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};

    void addIfPresent(String fieldName, dynamic value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('clickable', clickable);
    addIfPresent('color', color);
    addIfPresent('endCap', _capToJson(endCap));
    addIfPresent('geodesic', geodesic);
    addIfPresent('jointType', jointType.index);
    addIfPresent('startCap', _capToJson(startCap));
    addIfPresent('points', _pointsToJson(points));
    addIfPresent('width', width);
    addIfPresent('visible', visible);
    addIfPresent('zIndex', zIndex);
    return json;
  }
}
