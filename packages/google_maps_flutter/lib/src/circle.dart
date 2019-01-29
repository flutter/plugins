part of google_maps_flutter;

/// A circle is a list of points, where line segments are drawn between consecutive points.
class Circle {
  Circle(this._id, this._options);

  /// A unique identifier for this circle.
  ///
  /// The identifier is an arbitrary unique string.
  final String _id;
  String get id => _id;

  CircleOptions _options;

  /// The circle configuration options most recently applied programmatically
  /// via the map controller.
  CircleOptions get options => _options;
}

/// Configuration options for [Circle] instances.
///
/// When used to change configuration, null values will be interpreted as
/// "do not change this configuration option"; except for the pattern, a null pattern will
/// set the stroke pattern to the default (solid).
class CircleOptions {
  const CircleOptions({
    @required this.radius,
    @required this.center,
    this.consumeTapEvents,
    this.strokeColor,
    this.fillColor,
    this.jointType,
    this.pattern,
    this.visible,
    this.strokeWidth,
    this.zIndex,
  });

  /// If you want to handle events fired when the user taps the circle, set this property to true.
  /// You can change this value at any time. The default is false.
  final bool consumeTapEvents;

  /// Line segment color in ARGB format, the same format used by Color. The default value is black (0xff000000).
  final int strokeColor;

  /// Line segment color in ARGB format, the same format used by Color. The default value is black (0xff000000).
  final int fillColor;

  /// Circle segment stroke width in ARGB format, the same format used by Color. The default value is black (0xff000000).
  final double strokeWidth;

  final LatLng center;

  final int radius;

  /// The joint type defines the shape to be used when joining adjacent line segments at all vertices of the
  /// circle except the start and end vertices. See JointType for supported joint types. The default value is
  /// DEFAULT.
  final int jointType;

  /// The stroke pattern for the circle.
  ///
  /// Solid (default, represented by null) or a sequence of PatternItem objects to be repeated along the line.
  /// Available PatternItem types: Gap (defined by gap length in pixels), Dash (defined by line width and dash
  /// length in pixels) and Dot (circular, centered on the line, diameter defined by line width in pixels).
  final List<PatternItem> pattern;

  /// Indicates if the circle is visible or invisible, i.e., whether it is drawn on the map. An invisible
  /// circle is not drawn, but retains all of its other properties. The default is true, i.e., visible.
  final bool visible;

  /// The order in which this tile overlay is drawn with respect to other overlays. An overlay with a larger
  /// z-index is drawn over overlays with smaller z-indices. The order of overlays with the same z-index is
  /// arbitrary. The default zIndex is 0.
  final double zIndex;

  /// Default circle options.
  ///
  /// Specifies a circles that
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
  static const CircleOptions defaultOptions = CircleOptions(
    consumeTapEvents: true,
    strokeColor: 0xff000000,
    fillColor: null,
    radius: 500,
    center: LatLng(21.222, 21.323223),
    pattern: null,
    jointType: null,
    visible: true,
    strokeWidth: 1,
    zIndex: 0.0,
  );

  /// Creates a new options object whose values are the same as this instance,
  /// unless overwritten by the specified [changes].
  ///
  /// Returns this instance, if [changes] is null.
  CircleOptions copyWith(CircleOptions changes) {
    if (changes == null) {
      return this;
    }
    return CircleOptions(
      strokeColor: changes.strokeColor ?? strokeColor,
      fillColor: changes.fillColor ?? fillColor,
      radius: changes.radius ?? radius,
      center: changes.center ?? center,
      consumeTapEvents: changes.consumeTapEvents ?? consumeTapEvents,
      jointType: changes.jointType ?? jointType,
      pattern: changes.pattern,
      visible: changes.visible ?? visible,
      strokeWidth: changes.strokeWidth ?? strokeWidth,
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

    addIfPresent('radius', radius);
    addIfPresent('strokeColor', strokeColor);
    addIfPresent('strokeWidth', strokeWidth);
    addIfPresent('fillColor', fillColor);
    addIfPresent('jointType', jointType);
    addIfPresent('pattern', _patternToJson());
    addIfPresent('center', center?._toJson());
    addIfPresent('consumeTapEvents', consumeTapEvents);
    addIfPresent('visible', visible);
    addIfPresent('zIndex', zIndex);

    return json;
  }

  dynamic _patternToJson() {
    if (pattern == null) {
      return null;
    }

    final List<dynamic> result = <dynamic>[];
    for (final PatternItem patternItem in pattern) {
      if (patternItem != null) {
        result.add(patternItem._toJson());
      }
    }
    return result;
  }
}
