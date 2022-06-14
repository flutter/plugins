// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter_web;

// Default values for when the gmaps objects return null/undefined values.
final gmaps.LatLng _nullGmapsLatLng = gmaps.LatLng(0, 0);
final gmaps.LatLngBounds _nullGmapsLatLngBounds =
    gmaps.LatLngBounds(_nullGmapsLatLng, _nullGmapsLatLng);

// Defaults taken from the Google Maps Platform SDK documentation.
const String _defaultCssColor = '#000000';
const double _defaultCssOpacity = 0.0;

// Indices in the plugin side don't match with the ones
// in the gmaps lib. This translates from plugin -> gmaps.
final Map<int, gmaps.MapTypeId> _mapTypeToMapTypeId = <int, gmaps.MapTypeId>{
  0: gmaps.MapTypeId.ROADMAP, // "none" in the plugin
  1: gmaps.MapTypeId.ROADMAP,
  2: gmaps.MapTypeId.SATELLITE,
  3: gmaps.MapTypeId.TERRAIN,
  4: gmaps.MapTypeId.HYBRID,
};

// Converts a [Color] into a valid CSS value #RRGGBB.
String _getCssColor(Color color) {
  if (color == null) {
    return _defaultCssColor;
  }
  return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
}

// Extracts the opacity from a [Color].
double _getCssOpacity(Color color) {
  if (color == null) {
    return _defaultCssOpacity;
  }
  return color.opacity;
}

// Converts options from the plugin into gmaps.MapOptions that can be used by the JS SDK.
// The following options are not handled here, for various reasons:
// The following are not available in web, because the map doesn't rotate there:
//   compassEnabled
//   rotateGesturesEnabled
//   tiltGesturesEnabled
// mapToolbarEnabled is unused in web, there's no "map toolbar"
// myLocationButtonEnabled Widget not available in web yet, it needs to be built on top of the maps widget
//   See: https://developers.google.com/maps/documentation/javascript/examples/control-custom
// myLocationEnabled needs to be built through dart:html navigator.geolocation
//   See: https://api.dart.dev/stable/2.8.4/dart-html/Geolocation-class.html
// trafficEnabled is handled when creating the GMap object, since it needs to be added as a layer.
// trackCameraPosition is just a boolan value that indicates if the map has an onCameraMove handler.
// indoorViewEnabled seems to not have an equivalent in web
// buildingsEnabled seems to not have an equivalent in web
// padding seems to behave differently in web than mobile. You can't move UI elements in web.
gmaps.MapOptions _rawOptionsToGmapsOptions(Map<String, Object?> rawOptions) {
  final gmaps.MapOptions options = gmaps.MapOptions();

  if (_mapTypeToMapTypeId.containsKey(rawOptions['mapType'])) {
    options.mapTypeId = _mapTypeToMapTypeId[rawOptions['mapType']];
  }

  if (rawOptions['minMaxZoomPreference'] != null) {
    final List<Object?> minMaxPreference =
        rawOptions['minMaxZoomPreference']! as List<Object?>;
    options
      ..minZoom = minMaxPreference[0] as num?
      ..maxZoom = minMaxPreference[1] as num?;
  }

  if (rawOptions['cameraTargetBounds'] != null) {
    // Needs gmaps.MapOptions.restriction and gmaps.MapRestriction
    // see: https://developers.google.com/maps/documentation/javascript/reference/map#MapOptions.restriction
  }

  if (rawOptions['zoomControlsEnabled'] != null) {
    options.zoomControl = rawOptions['zoomControlsEnabled'] as bool?;
  }

  if (rawOptions['styles'] != null) {
    options.styles = rawOptions['styles'] as List<gmaps.MapTypeStyle?>?;
  }

  if (rawOptions['scrollGesturesEnabled'] == false ||
      rawOptions['zoomGesturesEnabled'] == false) {
    options.gestureHandling = 'none';
  } else {
    options.gestureHandling = 'auto';
  }

  // These don't have any rawOptions entry, but they seem to be off in the native maps.
  options.mapTypeControl = false;
  options.fullscreenControl = false;
  options.streetViewControl = false;

  return options;
}

gmaps.MapOptions _applyInitialPosition(
  CameraPosition initialPosition,
  gmaps.MapOptions options,
) {
  // Adjust the initial position, if passed...
  if (initialPosition != null) {
    options.zoom = initialPosition.zoom;
    options.center = gmaps.LatLng(
        initialPosition.target.latitude, initialPosition.target.longitude);
  }
  return options;
}

// Extracts the status of the traffic layer from the rawOptions map.
bool _isTrafficLayerEnabled(Map<String, Object?> rawOptions) {
  return rawOptions['trafficEnabled'] as bool? ?? false;
}

// The keys we'd expect to see in a serialized MapTypeStyle JSON object.
final Set<String> _mapStyleKeys = <String>{
  'elementType',
  'featureType',
  'stylers',
};

// Checks if the passed in Map contains some of the _mapStyleKeys.
bool _isJsonMapStyle(Map<String, Object?> value) {
  return _mapStyleKeys.intersection(value.keys.toSet()).isNotEmpty;
}

// Converts an incoming JSON-encoded Style info, into the correct gmaps array.
List<gmaps.MapTypeStyle> _mapStyles(String? mapStyleJson) {
  List<gmaps.MapTypeStyle> styles = <gmaps.MapTypeStyle>[];
  if (mapStyleJson != null) {
    styles = (json.decode(mapStyleJson, reviver: (Object? key, Object? value) {
      if (value is Map && _isJsonMapStyle(value as Map<String, Object?>)) {
        List<Object?> stylers = <Object?>[];
        if (value['stylers'] != null) {
          stylers = (value['stylers']! as List<Object?>)
              .map<Object?>((Object? e) => e != null ? jsify(e) : null)
              .toList();
        }
        return gmaps.MapTypeStyle()
          ..elementType = value['elementType'] as String?
          ..featureType = value['featureType'] as String?
          ..stylers = stylers;
      }
      return value;
    }) as List<Object?>)
        .where((Object? element) => element != null)
        .cast<gmaps.MapTypeStyle>()
        .toList();
    // .toList calls are required so the JS API understands the underlying data structure.
  }
  return styles;
}

gmaps.LatLng _latLngToGmLatLng(LatLng latLng) {
  return gmaps.LatLng(latLng.latitude, latLng.longitude);
}

LatLng _gmLatLngToLatLng(gmaps.LatLng latLng) {
  return LatLng(latLng.lat.toDouble(), latLng.lng.toDouble());
}

LatLngBounds _gmLatLngBoundsTolatLngBounds(gmaps.LatLngBounds latLngBounds) {
  return LatLngBounds(
    southwest: _gmLatLngToLatLng(latLngBounds.southWest),
    northeast: _gmLatLngToLatLng(latLngBounds.northEast),
  );
}

CameraPosition _gmViewportToCameraPosition(gmaps.GMap map) {
  return CameraPosition(
    target: _gmLatLngToLatLng(map.center ?? _nullGmapsLatLng),
    bearing: map.heading?.toDouble() ?? 0,
    tilt: map.tilt?.toDouble() ?? 0,
    zoom: map.zoom?.toDouble() ?? 0,
  );
}

// Convert plugin objects to gmaps.Options objects
// TODO(ditman): Move to their appropriate objects, maybe make them copy constructors?
// Marker.fromMarker(anotherMarker, moreOptions);

gmaps.InfoWindowOptions? _infoWindowOptionsFromMarker(Marker marker) {
  final String markerTitle = marker.infoWindow.title ?? '';
  final String markerSnippet = marker.infoWindow.snippet ?? '';

  // If both the title and snippet of an infowindow are empty, we don't really
  // want an infowindow...
  if ((markerTitle.isEmpty) && (markerSnippet.isEmpty)) {
    return null;
  }

  // Add an outer wrapper to the contents of the infowindow, we need it to listen
  // to click events...
  final HtmlElement container = DivElement()
    ..id = 'gmaps-marker-${marker.markerId.value}-infowindow';

  if (markerTitle.isNotEmpty) {
    final HtmlElement title = HeadingElement.h3()
      ..className = 'infowindow-title'
      ..innerText = markerTitle;
    container.children.add(title);
  }
  if (markerSnippet.isNotEmpty) {
    final HtmlElement snippet = DivElement()
      ..className = 'infowindow-snippet'
      // `sanitizeHtml` is used to clean the (potential) user input from (potential)
      // XSS attacks through the contents of the marker InfoWindow.
      // See: https://pub.dev/documentation/sanitize_html/latest/sanitize_html/sanitizeHtml.html
      // See: b/159137885, b/159598165
      // The NodeTreeSanitizer.trusted just tells setInnerHtml to leave the output
      // of `sanitizeHtml` untouched.
      // ignore: unsafe_html
      ..setInnerHtml(
        sanitizeHtml(markerSnippet),
        treeSanitizer: NodeTreeSanitizer.trusted,
      );
    container.children.add(snippet);
  }

  return gmaps.InfoWindowOptions()
    ..content = container
    ..zIndex = marker.zIndex;
  // TODO(ditman): Compute the pixelOffset of the infoWindow, from the size of the Marker,
  // and the marker.infoWindow.anchor property.
}

// Computes the options for a new [gmaps.Marker] from an incoming set of options
// [marker], and the existing marker registered with the map: [currentMarker].
// Preserves the position from the [currentMarker], if set.
gmaps.MarkerOptions _markerOptionsFromMarker(
  Marker marker,
  gmaps.Marker? currentMarker,
) {
  final List<Object?> iconConfig = marker.icon.toJson() as List<Object?>;
  gmaps.Icon? icon;

  if (iconConfig != null) {
    if (iconConfig[0] == 'fromAssetImage') {
      assert(iconConfig.length >= 2);
      // iconConfig[2] contains the DPIs of the screen, but that information is
      // already encoded in the iconConfig[1]

      icon = gmaps.Icon()
        ..url = ui.webOnlyAssetManager.getAssetUrl(iconConfig[1]! as String);

      // iconConfig[3] may contain the [width, height] of the image, if passed!
      if (iconConfig.length >= 4 && iconConfig[3] != null) {
        final List<Object?> rawIconSize = iconConfig[3]! as List<Object?>;
        final gmaps.Size size = gmaps.Size(
          rawIconSize[0] as num?,
          rawIconSize[1] as num?,
        );
        icon
          ..size = size
          ..scaledSize = size;
      }
    } else if (iconConfig[0] == 'fromBytes') {
      // Grab the bytes, and put them into a blob
      final List<int> bytes = iconConfig[1]! as List<int>;
      // Create a Blob from bytes, but let the browser figure out the encoding
      final Blob blob = Blob(<dynamic>[bytes]);
      icon = gmaps.Icon()..url = Url.createObjectUrlFromBlob(blob);
    }
  }
  return gmaps.MarkerOptions()
    ..position = currentMarker?.position ??
        gmaps.LatLng(
          marker.position.latitude,
          marker.position.longitude,
        )
    ..title = sanitizeHtml(marker.infoWindow.title ?? '')
    ..zIndex = marker.zIndex
    ..visible = marker.visible
    ..opacity = marker.alpha
    ..draggable = marker.draggable
    ..icon = icon;
  // TODO(ditman): Compute anchor properly, otherwise infowindows attach to the wrong spot.
  // Flat and Rotation are not supported directly on the web.
}

gmaps.CircleOptions _circleOptionsFromCircle(Circle circle) {
  final gmaps.CircleOptions circleOptions = gmaps.CircleOptions()
    ..strokeColor = _getCssColor(circle.strokeColor)
    ..strokeOpacity = _getCssOpacity(circle.strokeColor)
    ..strokeWeight = circle.strokeWidth
    ..fillColor = _getCssColor(circle.fillColor)
    ..fillOpacity = _getCssOpacity(circle.fillColor)
    ..center = gmaps.LatLng(circle.center.latitude, circle.center.longitude)
    ..radius = circle.radius
    ..visible = circle.visible
    ..zIndex = circle.zIndex;
  return circleOptions;
}

gmaps.PolygonOptions _polygonOptionsFromPolygon(
    gmaps.GMap googleMap, Polygon polygon) {
  // Convert all points to GmLatLng
  final List<gmaps.LatLng> path =
      polygon.points.map(_latLngToGmLatLng).toList();

  final bool isClockwisePolygon = _isPolygonClockwise(path);

  final List<List<gmaps.LatLng>> paths = <List<gmaps.LatLng>>[path];

  for (int i = 0; i < polygon.holes.length; i++) {
    final List<LatLng> hole = polygon.holes[i];
    final List<gmaps.LatLng> correctHole = _ensureHoleHasReverseWinding(
      hole,
      isClockwisePolygon,
      holeId: i,
      polygonId: polygon.polygonId,
    );
    paths.add(correctHole);
  }

  return gmaps.PolygonOptions()
    ..paths = paths
    ..strokeColor = _getCssColor(polygon.strokeColor)
    ..strokeOpacity = _getCssOpacity(polygon.strokeColor)
    ..strokeWeight = polygon.strokeWidth
    ..fillColor = _getCssColor(polygon.fillColor)
    ..fillOpacity = _getCssOpacity(polygon.fillColor)
    ..visible = polygon.visible
    ..zIndex = polygon.zIndex
    ..geodesic = polygon.geodesic;
}

List<gmaps.LatLng> _ensureHoleHasReverseWinding(
  List<LatLng> hole,
  bool polyIsClockwise, {
  required int holeId,
  required PolygonId polygonId,
}) {
  List<gmaps.LatLng> holePath = hole.map(_latLngToGmLatLng).toList();
  final bool holeIsClockwise = _isPolygonClockwise(holePath);

  if (holeIsClockwise == polyIsClockwise) {
    holePath = holePath.reversed.toList();
    if (kDebugMode) {
      print('Hole [$holeId] in Polygon [${polygonId.value}] has been reversed.'
          ' Ensure holes in polygons are "wound in the opposite direction to the outer path."'
          ' More info: https://github.com/flutter/flutter/issues/74096');
    }
  }

  return holePath;
}

/// Calculates the direction of a given Polygon
/// based on: https://stackoverflow.com/a/1165943
///
/// returns [true] if clockwise [false] if counterclockwise
///
/// This method expects that the incoming [path] is a `List` of well-formed,
/// non-null [gmaps.LatLng] objects.
///
/// Currently, this method is only called from [_polygonOptionsFromPolygon], and
/// the `path` is a transformed version of [Polygon.points] or each of the
/// [Polygon.holes], guaranteeing that `lat` and `lng` can be accessed with `!`.
bool _isPolygonClockwise(List<gmaps.LatLng> path) {
  double direction = 0.0;
  for (int i = 0; i < path.length; i++) {
    direction = direction +
        ((path[(i + 1) % path.length].lat - path[i].lat) *
            (path[(i + 1) % path.length].lng + path[i].lng));
  }
  return direction >= 0;
}

gmaps.PolylineOptions _polylineOptionsFromPolyline(
    gmaps.GMap googleMap, Polyline polyline) {
  final List<gmaps.LatLng> paths =
      polyline.points.map(_latLngToGmLatLng).toList();

  return gmaps.PolylineOptions()
    ..path = paths
    ..strokeWeight = polyline.width
    ..strokeColor = _getCssColor(polyline.color)
    ..strokeOpacity = _getCssOpacity(polyline.color)
    ..visible = polyline.visible
    ..zIndex = polyline.zIndex
    ..geodesic = polyline.geodesic;
//  this.endCap = Cap.buttCap,
//  this.jointType = JointType.mitered,
//  this.patterns = const <PatternItem>[],
//  this.startCap = Cap.buttCap,
//  this.width = 10,
}

// Translates a [CameraUpdate] into operations on a [gmaps.GMap].
void _applyCameraUpdate(gmaps.GMap map, CameraUpdate update) {
  final List<dynamic> json = update.toJson() as List<dynamic>;
  switch (json[0]) {
    case 'newCameraPosition':
      map.heading = json[1]['bearing'] as num?;
      map.zoom = json[1]['zoom'] as num?;
      map.panTo(
        gmaps.LatLng(
          json[1]['target'][0] as num?,
          json[1]['target'][1] as num?,
        ),
      );
      map.tilt = json[1]['tilt'] as num?;
      break;
    case 'newLatLng':
      map.panTo(gmaps.LatLng(json[1][0] as num?, json[1][1] as num?));
      break;
    case 'newLatLngZoom':
      map.zoom = json[2] as num?;
      map.panTo(gmaps.LatLng(json[1][0] as num?, json[1][1] as num?));
      break;
    case 'newLatLngBounds':
      map.fitBounds(
        gmaps.LatLngBounds(
          gmaps.LatLng(json[1][0][0] as num?, json[1][0][1] as num?),
          gmaps.LatLng(json[1][1][0] as num?, json[1][1][1] as num?),
        ),
      );
      // padding = json[2];
      // Needs package:google_maps ^4.0.0 to adjust the padding in fitBounds
      break;
    case 'scrollBy':
      map.panBy(json[1] as num?, json[2] as num?);
      break;
    case 'zoomBy':
      gmaps.LatLng? focusLatLng;
      final double zoomDelta = json[1] as double? ?? 0;
      // Web only supports integer changes...
      final int newZoomDelta =
          zoomDelta < 0 ? zoomDelta.floor() : zoomDelta.ceil();
      if (json.length == 3) {
        // With focus
        try {
          focusLatLng =
              _pixelToLatLng(map, json[2][0] as int, json[2][1] as int);
        } catch (e) {
          // https://github.com/a14n/dart-google-maps/issues/87
          // print('Error computing new focus LatLng. JS Error: ' + e.toString());
        }
      }
      map.zoom = (map.zoom ?? 0) + newZoomDelta;
      if (focusLatLng != null) {
        map.panTo(focusLatLng);
      }
      break;
    case 'zoomIn':
      map.zoom = (map.zoom ?? 0) + 1;
      break;
    case 'zoomOut':
      map.zoom = (map.zoom ?? 0) - 1;
      break;
    case 'zoomTo':
      map.zoom = json[1] as num?;
      break;
    default:
      throw UnimplementedError('Unimplemented CameraMove: ${json[0]}.');
  }
}

// original JS by: Byron Singh (https://stackoverflow.com/a/30541162)
gmaps.LatLng _pixelToLatLng(gmaps.GMap map, int x, int y) {
  final gmaps.LatLngBounds? bounds = map.bounds;
  final gmaps.Projection? projection = map.projection;
  final num? zoom = map.zoom;

  assert(
      bounds != null, 'Map Bounds required to compute LatLng of screen x/y.');
  assert(projection != null,
      'Map Projection required to compute LatLng of screen x/y');
  assert(zoom != null,
      'Current map zoom level required to compute LatLng of screen x/y');

  final gmaps.LatLng ne = bounds!.northEast;
  final gmaps.LatLng sw = bounds.southWest;

  final gmaps.Point topRight = projection!.fromLatLngToPoint!(ne)!;
  final gmaps.Point bottomLeft = projection.fromLatLngToPoint!(sw)!;

  final int scale = 1 << (zoom!.toInt()); // 2 ^ zoom

  final gmaps.Point point =
      gmaps.Point((x / scale) + bottomLeft.x!, (y / scale) + topRight.y!);

  return projection.fromPointToLatLng!(point)!;
}
