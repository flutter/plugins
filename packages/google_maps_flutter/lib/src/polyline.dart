part of google_maps_flutter;

/// A polyline is a list of points, where line segments are drawn between consecutive points.
class Polyline {
  Polyline(this._id, this._options);

  /// A unique identifier for this polyline.
  ///
  /// The identifier is an arbitrary unique string.
  final String _id;
  String get id => _id;

  PolylineOptions _options;

  /// The polyline configuration options most recently applied programmatically
  /// via the map controller.
  PolylineOptions get options => _options;
}

/// Configuration options for [Polyline] instances.
///
/// When used to change configuration, null values will be interpreted as
/// "do not change this configuration option".
class PolylineOptions {
  const PolylineOptions({
    this.consumeTapEvents,
    this.color,
    this.endCap,
    this.geodesic,
    this.jointType,
    this.points,
    this.pattern,
    this.startCap,
    this.visible,
    this.width,
    this.zIndex,
  });

  /// If you want to handle events fired when the user taps the polyline, set this property to true.
  /// You can change this value at any time. The default is false.
  final bool consumeTapEvents;

  /// Line segment color in ARGB format, the same format used by Color. The default value is black (0xff000000).
  final int color;

  /// The cap at the end vertex of the polyline. The default end cap is ButtCap.
  final Cap endCap;

  /// Indicates whether the segments of the polyline should be drawn as geodesics, as opposed to straight lines
  /// on the Mercator projection. A geodesic is the shortest path between two points on the Earth's surface.
  /// The geodesic curve is constructed assuming the Earth is a sphere
  final bool geodesic;

  /// The joint type defines the shape to be used when joining adjacent line segments at all vertices of the
  /// polyline except the start and end vertices. See JointType for supported joint types. The default value is
  /// mitered.
  final int jointType;

  /// The stroke pattern for the polyline.
  ///
  /// Solid or a sequence of PatternItem objects to be repeated along the line.
  /// Available PatternItem types: Gap (defined by gap length in pixels), Dash (defined by line width and dash
  /// length in pixels) and Dot (circular, centered on the line, diameter defined by line width in pixels).
  final List<PatternItem> pattern;

  /// The vertices of the line. Line segments are drawn between consecutive points. A polyline is not closed by
  /// default; to form a closed polyline, the start and end points must be the same.
  final List<LatLng> points;

  /// The cap at the start vertex of the polyline. The default start cap is ButtCap.
  final Cap startCap;

  /// Indicates if the polyline is visible or invisible, i.e., whether it is drawn on the map. An invisible
  /// polyline is not drawn, but retains all of its other properties. The default is true, i.e., visible.
  final bool visible;

  /// Line segment width in screen pixels. The width is constant and independent of the camera's zoom level.
  /// The default value is 10.
  final double width;

  /// The order in which this tile overlay is drawn with respect to other overlays. An overlay with a larger
  /// z-index is drawn over overlays with smaller z-indices. The order of overlays with the same z-index is
  /// arbitrary. The default zIndex is 0.
  final double zIndex;

  /// Default polyline options.
  ///
  /// Specifies a polylines that
  /// * does not consume tap events; [consumeTapEvents] is false
  /// * is black; [color] is 0xff000000
  /// * the cap set for the end vertex is ButtCap; [endCap] is ButtCap
  /// * segments are not drawn as geodesics; [geodesic] is false
  /// * joint types are mitered; [jointType] is mitered
  /// * has no points; [points] is null
  /// * the cap for the start vertex is ButtCap; [startCap] is ButtCap
  /// * is visible; [visible] is true
  /// * has a width of 10; [width] is 10
  /// * is placed at the base of the drawing order; [zIndex] is 0.0
  static const PolylineOptions defaultOptions = PolylineOptions(
    consumeTapEvents: false,
    color: 0xff000000,
    endCap: Cap.buttCap,
    geodesic: false,
    jointType: JointType.mitered,
    pattern: <PatternItem>[],
    points: null,
    startCap: Cap.buttCap,
    visible: true,
    width: 10,
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
      color: changes.color ?? color,
      consumeTapEvents: changes.consumeTapEvents ?? consumeTapEvents,
      endCap: changes.endCap ?? endCap,
      geodesic: changes.geodesic ?? geodesic,
      jointType: changes.jointType ?? jointType,
      pattern: changes.pattern ?? pattern,
      points: changes.points ?? points,
      startCap: changes.startCap ?? startCap,
      visible: changes.visible ?? visible,
      width: changes.width ?? width,
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

    addIfPresent('consumeTapEvents', consumeTapEvents);
    addIfPresent('color', color);
    addIfPresent('endCap', endCap?._toJson());
    addIfPresent('geodesic', geodesic);
    addIfPresent('jointType', jointType);
    addIfPresent('startCap', startCap?._toJson());
    addIfPresent('visible', visible);
    addIfPresent('width', width);
    addIfPresent('zIndex', zIndex);

    if (points != null) {
      json['points'] = _pointsToJson();
    }

    if (pattern != null) {
      json['pattern'] = _patternToJson();
    }

    return json;
  }

  dynamic _pointsToJson() {
    final List<dynamic> result = <dynamic>[];
    for (final LatLng point in points) {
      result.add(point._toJson());
    }
    return result;
  }

  dynamic _patternToJson() {
    final List<dynamic> result = <dynamic>[];
    for (final PatternItem patternItem in pattern) {
      if (patternItem != null) {
        result.add(patternItem._toJson());
      }
    }
    return result;
  }
}
