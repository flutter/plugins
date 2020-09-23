// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter_web;

final _nullLatLng = LatLng(0, 0);
final _nullLatLngBounds = LatLngBounds(
  northeast: _nullLatLng,
  southwest: _nullLatLng,
);

// Defaults taken from the Google Maps Platform SDK documentation.
final _defaultStrokeColor = Colors.black.value;
final _defaultFillColor = Colors.transparent.value;

// Indices in the plugin side don't match with the ones
// in the gmaps lib. This translates from plugin -> gmaps.
final _mapTypeToMapTypeId = {
  0: gmaps.MapTypeId.ROADMAP, // "none" in the plugin
  1: gmaps.MapTypeId.ROADMAP,
  2: gmaps.MapTypeId.SATELLITE,
  3: gmaps.MapTypeId.TERRAIN,
  4: gmaps.MapTypeId.HYBRID,
};

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
gmaps.MapOptions _rawOptionsToGmapsOptions(Map<String, dynamic> rawOptions) {
  Map<String, dynamic> optionsUpdate = rawOptions['options'] ?? {};

  gmaps.MapOptions options = gmaps.MapOptions();

  if (_mapTypeToMapTypeId.containsKey(optionsUpdate['mapType'])) {
    options.mapTypeId = _mapTypeToMapTypeId[optionsUpdate['mapType']];
  }

  if (optionsUpdate['minMaxZoomPreference'] != null) {
    options
      ..minZoom = optionsUpdate['minMaxZoomPreference'][0]
      ..maxZoom = optionsUpdate['minMaxZoomPreference'][1];
  }

  if (optionsUpdate['cameraTargetBounds'] != null) {
    // Needs gmaps.MapOptions.restriction and gmaps.MapRestriction
    // see: https://developers.google.com/maps/documentation/javascript/reference/map#MapOptions.restriction
  }

  if (optionsUpdate['zoomControlsEnabled'] != null) {
    options.zoomControl = optionsUpdate['zoomControlsEnabled'];
  }

  if (optionsUpdate['styles'] != null) {
    options.styles = optionsUpdate['styles'];
  }

  if (optionsUpdate['scrollGesturesEnabled'] == false ||
      optionsUpdate['zoomGesturesEnabled'] == false) {
    options.gestureHandling = 'none';
  } else {
    options.gestureHandling = 'auto';
  }

  // These don't have any optionUpdate entry, but they seem to be off in the native maps.
  options.mapTypeControl = false;
  options.fullscreenControl = false;
  options.streetViewControl = false;

  return options;
}

gmaps.MapOptions _applyInitialPosition(
  Map<String, dynamic> rawOptions,
  gmaps.MapOptions options,
) {
  // Adjust the initial position, if passed...
  Map<String, dynamic> initialPosition = rawOptions['initialCameraPosition'];
  if (initialPosition != null) {
    final position = CameraPosition.fromMap(initialPosition);
    options.zoom = position.zoom;
    options.center =
        gmaps.LatLng(position.target.latitude, position.target.longitude);
  }
  return options;
}

// Extracts the status of the traffic layer from the rawOptions map.
bool _isTrafficLayerEnabled(Map<String, dynamic> rawOptions) {
  if (rawOptions['options'] == null) {
    return false;
  }
  return rawOptions['options']['trafficEnabled'] ?? false;
}

// Coverts the incoming JSON object into a List of MapTypeStyler objects.
List<gmaps.MapTypeStyler> _parseStylers(List stylerJsons) {
  return stylerJsons?.map((styler) {
    return gmaps.MapTypeStyler()
      ..color = styler['color']
      ..gamma = styler['gamma']
      ..hue = styler['hue']
      ..invertLightness = styler['invertLightness']
      ..lightness = styler['lightness']
      ..saturation = styler['saturation']
      ..visibility = styler['visibility']
      ..weight = styler['weight'];
  })?.toList();
}

// Converts a String to its corresponding MapTypeStyleElementType enum value.
final _elementTypeToEnum = <String, gmaps.MapTypeStyleElementType>{
  'all': gmaps.MapTypeStyleElementType.ALL,
  'geometry': gmaps.MapTypeStyleElementType.GEOMETRY,
  'geometry.fill': gmaps.MapTypeStyleElementType.GEOMETRY_FILL,
  'geometry.stroke': gmaps.MapTypeStyleElementType.GEOMETRY_STROKE,
  'labels': gmaps.MapTypeStyleElementType.LABELS,
  'labels.icon': gmaps.MapTypeStyleElementType.LABELS_ICON,
  'labels.text': gmaps.MapTypeStyleElementType.LABELS_TEXT,
  'labels.text.fill': gmaps.MapTypeStyleElementType.LABELS_TEXT_FILL,
  'labels.text.stroke': gmaps.MapTypeStyleElementType.LABELS_TEXT_STROKE,
};

// Converts a String to its corresponding MapTypeStyleFeatureType enum value.
final _featureTypeToEnum = <String, gmaps.MapTypeStyleFeatureType>{
  'administrative': gmaps.MapTypeStyleFeatureType.ADMINISTRATIVE,
  'administrative.country':
      gmaps.MapTypeStyleFeatureType.ADMINISTRATIVE_COUNTRY,
  'administrative.land_parcel':
      gmaps.MapTypeStyleFeatureType.ADMINISTRATIVE_LAND_PARCEL,
  'administrative.locality':
      gmaps.MapTypeStyleFeatureType.ADMINISTRATIVE_LOCALITY,
  'administrative.neighborhood':
      gmaps.MapTypeStyleFeatureType.ADMINISTRATIVE_NEIGHBORHOOD,
  'administrative.province':
      gmaps.MapTypeStyleFeatureType.ADMINISTRATIVE_PROVINCE,
  'all': gmaps.MapTypeStyleFeatureType.ALL,
  'landscape': gmaps.MapTypeStyleFeatureType.LANDSCAPE,
  'landscape.man_made': gmaps.MapTypeStyleFeatureType.LANDSCAPE_MAN_MADE,
  'landscape.natural': gmaps.MapTypeStyleFeatureType.LANDSCAPE_NATURAL,
  'landscape.natural.landcover':
      gmaps.MapTypeStyleFeatureType.LANDSCAPE_NATURAL_LANDCOVER,
  'landscape.natural.terrain':
      gmaps.MapTypeStyleFeatureType.LANDSCAPE_NATURAL_TERRAIN,
  'poi': gmaps.MapTypeStyleFeatureType.POI,
  'poi.attraction': gmaps.MapTypeStyleFeatureType.POI_ATTRACTION,
  'poi.business': gmaps.MapTypeStyleFeatureType.POI_BUSINESS,
  'poi.government': gmaps.MapTypeStyleFeatureType.POI_GOVERNMENT,
  'poi.medical': gmaps.MapTypeStyleFeatureType.POI_MEDICAL,
  'poi.park': gmaps.MapTypeStyleFeatureType.POI_PARK,
  'poi.place_of_worship': gmaps.MapTypeStyleFeatureType.POI_PLACE_OF_WORSHIP,
  'poi.school': gmaps.MapTypeStyleFeatureType.POI_SCHOOL,
  'poi.sports_complex': gmaps.MapTypeStyleFeatureType.POI_SPORTS_COMPLEX,
  'road': gmaps.MapTypeStyleFeatureType.ROAD,
  'road.arterial': gmaps.MapTypeStyleFeatureType.ROAD_ARTERIAL,
  'road.highway': gmaps.MapTypeStyleFeatureType.ROAD_HIGHWAY,
  'road.highway.controlled_access':
      gmaps.MapTypeStyleFeatureType.ROAD_HIGHWAY_CONTROLLED_ACCESS,
  'road.local': gmaps.MapTypeStyleFeatureType.ROAD_LOCAL,
  'transit': gmaps.MapTypeStyleFeatureType.TRANSIT,
  'transit.line': gmaps.MapTypeStyleFeatureType.TRANSIT_LINE,
  'transit.station': gmaps.MapTypeStyleFeatureType.TRANSIT_STATION,
  'transit.station.airport':
      gmaps.MapTypeStyleFeatureType.TRANSIT_STATION_AIRPORT,
  'transit.station.bus': gmaps.MapTypeStyleFeatureType.TRANSIT_STATION_BUS,
  'transit.station.rail': gmaps.MapTypeStyleFeatureType.TRANSIT_STATION_RAIL,
  'water': gmaps.MapTypeStyleFeatureType.WATER,
};

// The keys we'd expect to see in a serialized MapTypeStyle JSON object.
final _mapStyleKeys = {
  'elementType',
  'featureType',
  'stylers',
};

// Checks if the passed in Map contains some of the _mapStyleKeys.
bool _isJsonMapStyle(Map value) {
  return _mapStyleKeys.intersection(value.keys.toSet()).isNotEmpty;
}

// Converts an incoming JSON-encoded Style info, into the correct gmaps array.
List<gmaps.MapTypeStyle> _mapStyles(String mapStyleJson) {
  List<gmaps.MapTypeStyle> styles = [];
  if (mapStyleJson != null) {
    styles = json.decode(mapStyleJson, reviver: (key, value) {
      if (value is Map && _isJsonMapStyle(value)) {
        return gmaps.MapTypeStyle()
          ..elementType = _elementTypeToEnum[value['elementType']]
          ..featureType = _featureTypeToEnum[value['featureType']]
          ..stylers = _parseStylers(value['stylers']);
      }
      return value;
    }).cast<gmaps.MapTypeStyle>();
  }
  return styles;
}

gmaps.LatLng _latLngToGmLatLng(LatLng latLng) {
  if (latLng == null) return null;
  return gmaps.LatLng(latLng.latitude, latLng.longitude);
}

LatLng _gmLatLngToLatLng(gmaps.LatLng latLng) {
  if (latLng == null) return _nullLatLng;
  return LatLng(latLng.lat, latLng.lng);
}

LatLngBounds _gmLatLngBoundsTolatLngBounds(gmaps.LatLngBounds latLngBounds) {
  if (latLngBounds == null) {
    return _nullLatLngBounds;
  }

  return LatLngBounds(
    southwest: _gmLatLngToLatLng(latLngBounds.southWest),
    northeast: _gmLatLngToLatLng(latLngBounds.northEast),
  );
}

CameraPosition _gmViewportToCameraPosition(gmaps.GMap map) {
  return CameraPosition(
    target: _gmLatLngToLatLng(map.center),
    bearing: map.heading ?? 0,
    tilt: map.tilt ?? 0,
    zoom: map.zoom?.toDouble() ?? 10,
  );
}

Set<Marker> _rawOptionsToInitialMarkers(Map<String, dynamic> rawOptions) {
  final List<Map<String, dynamic>> list = rawOptions['markersToAdd'];
  Set<Marker> markers = {};
  markers.addAll(list?.map((rawMarker) {
        Offset offset;
        LatLng position;
        InfoWindow infoWindow;
        if (rawMarker['anchor'] != null) {
          offset = Offset((rawMarker['anchor'][0]), (rawMarker['anchor'][1]));
        }
        if (rawMarker['position'] != null) {
          position = LatLng.fromJson(rawMarker['position']);
        }
        if (rawMarker['infoWindow'] != null || rawMarker['snippet'] != null) {
          String title = rawMarker['infoWindow'] != null
              ? rawMarker['infoWindow']['title']
              : null;
          infoWindow = InfoWindow(
            title: title ?? '',
            snippet: rawMarker['snippet'] ?? '',
          );
        }
        return Marker(
          markerId: MarkerId(rawMarker['markerId']),
          alpha: rawMarker['alpha'],
          anchor: offset,
          consumeTapEvents: rawMarker['consumeTapEvents'],
          draggable: rawMarker['draggable'],
          flat: rawMarker['flat'],
          // TODO: Doesn't this support custom icons?
          icon: BitmapDescriptor.defaultMarker,
          infoWindow: infoWindow,
          position: position ?? _nullLatLng,
          rotation: rawMarker['rotation'],
          visible: rawMarker['visible'],
          zIndex: rawMarker['zIndex'],
        );
      }) ??
      []);
  return markers;
}

Set<Circle> _rawOptionsToInitialCircles(Map<String, dynamic> rawOptions) {
  final List<Map<String, dynamic>> list = rawOptions['circlesToAdd'];
  Set<Circle> circles = {};
  circles.addAll(list?.map((rawCircle) {
        LatLng center;
        if (rawCircle['center'] != null) {
          center = LatLng.fromJson(rawCircle['center']);
        }
        return Circle(
          circleId: CircleId(rawCircle['circleId']),
          consumeTapEvents: rawCircle['consumeTapEvents'],
          fillColor: Color(rawCircle['fillColor'] ?? _defaultFillColor),
          center: center ?? _nullLatLng,
          radius: rawCircle['radius'],
          strokeColor: Color(rawCircle['strokeColor'] ?? _defaultStrokeColor),
          strokeWidth: rawCircle['strokeWidth'],
          visible: rawCircle['visible'],
          zIndex: rawCircle['zIndex'],
        );
      }) ??
      []);
  return circles;
}

// Unsupported on the web: endCap, jointType, patterns and startCap.
Set<Polyline> _rawOptionsToInitialPolylines(Map<String, dynamic> rawOptions) {
  final List<Map<String, dynamic>> list = rawOptions['polylinesToAdd'];
  Set<Polyline> polylines = {};
  polylines.addAll(list?.map((rawPolyline) {
        return Polyline(
          polylineId: PolylineId(rawPolyline['polylineId']),
          consumeTapEvents: rawPolyline['consumeTapEvents'],
          color: Color(rawPolyline['color'] ?? _defaultStrokeColor),
          geodesic: rawPolyline['geodesic'],
          visible: rawPolyline['visible'],
          zIndex: rawPolyline['zIndex'],
          width: rawPolyline['width'],
          points: rawPolyline['points']
              ?.map((rawPoint) => LatLng.fromJson(rawPoint))
              ?.toList(),
        );
      }) ??
      []);
  return polylines;
}

Set<Polygon> _rawOptionsToInitialPolygons(Map<String, dynamic> rawOptions) {
  final List<Map<String, dynamic>> list = rawOptions['polygonsToAdd'];
  Set<Polygon> polygons = {};

  polygons.addAll(list?.map((rawPolygon) {
        return Polygon(
          polygonId: PolygonId(rawPolygon['polygonId']),
          consumeTapEvents: rawPolygon['consumeTapEvents'],
          fillColor: Color(rawPolygon['fillColor'] ?? _defaultFillColor),
          geodesic: rawPolygon['geodesic'],
          strokeColor: Color(rawPolygon['strokeColor'] ?? _defaultStrokeColor),
          strokeWidth: rawPolygon['strokeWidth'],
          visible: rawPolygon['visible'],
          zIndex: rawPolygon['zIndex'],
          points: rawPolygon['points']
              ?.map((rawPoint) => LatLng.fromJson(rawPoint))
              ?.toList(),
        );
      }) ??
      []);
  return polygons;
}

// Convert plugin objects to gmaps.Options objects
// TODO: Move to their appropriate objects, maybe make these copy constructors:
// Marker.fromMarker(anotherMarker, moreOptions);

gmaps.InfoWindowOptions _infoWindowOptionsFromMarker(Marker marker) {
  if ((marker.infoWindow?.title?.isEmpty ?? true) &&
      (marker.infoWindow?.snippet?.isEmpty ?? true)) {
    return null;
  }

  final content = '<h3 class="infowindow-title">' +
      sanitizeHtml(marker.infoWindow.title ?? "") +
      '</h3>' +
      sanitizeHtml(marker.infoWindow.snippet ?? "");

  return gmaps.InfoWindowOptions()
    ..content = content
    ..zIndex = marker.zIndex;
  // TODO: Compute the pixelOffset of the infoWindow, from the size of the Marker,
  // and the marker.infoWindow.anchor property.
}

// Computes the options for a new [gmaps.Marker] from an incoming set of options
// [marker], and the existing marker registered with the map: [currentMarker].
// Preserves the position from the [currentMarker], if set.
gmaps.MarkerOptions _markerOptionsFromMarker(
  Marker marker,
  gmaps.Marker currentMarker,
) {
  final iconConfig = marker.icon?.toJson() as List;
  gmaps.Icon icon;

  if (iconConfig != null) {
    if (iconConfig[0] == 'fromAssetImage') {
      assert(iconConfig.length >= 2);
      // iconConfig[2] contains the DPIs of the screen, but that information is
      // already encoded in the iconConfig[1]

      icon = gmaps.Icon()
        ..url = ui.webOnlyAssetManager.getAssetUrl(iconConfig[1]);

      // iconConfig[3] may contain the [width, height] of the image, if passed!
      if (iconConfig.length >= 4 && iconConfig[3] != null) {
        final size = gmaps.Size(iconConfig[3][0], iconConfig[3][1]);
        icon
          ..size = size
          ..scaledSize = size;
      }
    }
  }
  return gmaps.MarkerOptions()
    ..position = currentMarker?.position ??
        gmaps.LatLng(
          marker.position.latitude,
          marker.position.longitude,
        )
    ..title = sanitizeHtml(marker.infoWindow?.title ?? "")
    ..zIndex = marker.zIndex
    ..visible = marker.visible
    ..opacity = marker.alpha
    ..draggable = marker.draggable
    ..icon = icon;
  // TODO: Compute anchor properly, otherwise infowindows attach to the wrong spot.
  // Flat and Rotation are not supported directly on the web.
}

gmaps.CircleOptions _circleOptionsFromCircle(Circle circle) {
  final populationOptions = gmaps.CircleOptions()
    ..strokeColor = '#' + circle.strokeColor.value.toRadixString(16)
    ..strokeOpacity = 0.8
    ..strokeWeight = circle.strokeWidth
    ..fillColor = '#' + circle.fillColor.value.toRadixString(16)
    ..fillOpacity = 0.6
    ..center = gmaps.LatLng(circle.center.latitude, circle.center.longitude)
    ..radius = circle.radius
    ..visible = circle.visible;
  return populationOptions;
}

gmaps.PolygonOptions _polygonOptionsFromPolygon(
    gmaps.GMap googleMap, Polygon polygon) {
  List<gmaps.LatLng> paths = [];
  polygon.points.forEach((point) {
    paths.add(_latLngToGmLatLng(point));
  });
  return gmaps.PolygonOptions()
    ..paths = paths
    ..strokeColor = '#' + polygon.strokeColor.value.toRadixString(16)
    ..strokeOpacity = 0.8
    ..strokeWeight = polygon.strokeWidth
    ..fillColor = '#' + polygon.fillColor.value.toRadixString(16)
    ..fillOpacity = 0.35
    ..visible = polygon.visible
    ..zIndex = polygon.zIndex
    ..geodesic = polygon.geodesic;
}

gmaps.PolylineOptions _polylineOptionsFromPolyline(
    gmaps.GMap googleMap, Polyline polyline) {
  List<gmaps.LatLng> paths = [];
  polyline.points.forEach((point) {
    paths.add(_latLngToGmLatLng(point));
  });

  return gmaps.PolylineOptions()
    ..path = paths
    ..strokeOpacity = 1.0
    ..strokeWeight = polyline.width
    ..strokeColor = '#' + polyline.color.value.toRadixString(16).substring(0, 6)
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
  final json = update.toJson();
  switch (json[0]) {
    case 'newCameraPosition':
      map.heading = json[1]['bearing'];
      map.zoom = json[1]['zoom'];
      map.panTo(gmaps.LatLng(json[1]['target'][0], json[1]['target'][1]));
      map.tilt = json[1]['tilt'];
      break;
    case 'newLatLng':
      map.panTo(gmaps.LatLng(json[1][0], json[1][1]));
      break;
    case 'newLatLngZoom':
      map.zoom = json[2];
      map.panTo(gmaps.LatLng(json[1][0], json[1][1]));
      break;
    case 'newLatLngBounds':
      map.fitBounds(gmaps.LatLngBounds(
          gmaps.LatLng(json[1][0][0], json[1][0][1]),
          gmaps.LatLng(json[1][1][0], json[1][1][1])));
      // padding = json[2];
      // Needs package:google_maps ^4.0.0 to adjust the padding in fitBounds
      break;
    case 'scrollBy':
      map.panBy(json[1], json[2]);
      break;
    case 'zoomBy':
      gmaps.LatLng focusLatLng;
      double zoomDelta = json[1] ?? 0;
      // Web only supports integer changes...
      int newZoomDelta = zoomDelta < 0 ? zoomDelta.floor() : zoomDelta.ceil();
      if (json.length == 3) {
        // With focus
        try {
          focusLatLng = _pixelToLatLng(map, json[2][0], json[2][1]);
        } catch (e) {
          // https://github.com/a14n/dart-google-maps/issues/87
          // print('Error computing new focus LatLng. JS Error: ' + e.toString());
        }
      }
      map.zoom = map.zoom + newZoomDelta;
      if (focusLatLng != null) {
        map.panTo(focusLatLng);
      }
      break;
    case 'zoomIn':
      map.zoom++;
      break;
    case 'zoomOut':
      map.zoom--;
      break;
    case 'zoomTo':
      map.zoom = json[1];
      break;
    default:
      throw UnimplementedError('Unimplemented CameraMove: ${json[0]}.');
  }
}

// original JS by: Byron Singh (https://stackoverflow.com/a/30541162)
gmaps.LatLng _pixelToLatLng(gmaps.GMap map, int x, int y) {
  final ne = map.bounds.northEast;
  final sw = map.bounds.southWest;
  final projection = map.projection;

  final topRight = projection.fromLatLngToPoint(ne);
  final bottomLeft = projection.fromLatLngToPoint(sw);

  final scale = 1 << map.zoom; // 2 ^ zoom

  final point =
      gmaps.Point((x / scale) + bottomLeft.x, (y / scale) + topRight.y);

  return projection.fromPointToLatLng(point);
}
