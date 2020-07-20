part of google_maps_flutter_web;

// Indices in the plugin side don't match with the ones
// in the gmaps lib. This translates from plugin -> gmaps.
final _mapTypeToMapTypeId = {
  0: gmaps.MapTypeId.ROADMAP, // "none" in the plugin
  1: gmaps.MapTypeId.ROADMAP,
  2: gmaps.MapTypeId.SATELLITE,
  3: gmaps.MapTypeId.TERRAIN,
  4: gmaps.MapTypeId.HYBRID,
};

/// Converts options from the plugin into gmaps.MapOptions that can be used by the JS SDK.
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
gmaps.MapOptions _optionsFromParams(Map<String, dynamic> optionsUpdate, {
      gmaps.MapOptions existingOptions,
    }) {

  gmaps.MapOptions options = existingOptions ?? gmaps.MapOptions();

  if(_mapTypeToMapTypeId.containsKey(optionsUpdate['mapType'])) {
    options.mapTypeId = _mapTypeToMapTypeId[optionsUpdate['mapType']];
  }

  if (optionsUpdate['minMaxZoomPreference'] != null) {
    options
      ..minZoom   = optionsUpdate['minMaxZoomPreference'][0]
      ..maxZoom   = optionsUpdate['minMaxZoomPreference'][1];
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

  if (optionsUpdate['scrollGesturesEnabled'] == false || optionsUpdate['zoomGesturesEnabled'] == false) {
    options.gestureHandling = 'none';
  } else {
    options.gestureHandling = 'auto';
  }

  // These don't have any optionUpdate entry, but they seem to be off in the native maps.
  options.mapTypeControl = optionsUpdate['mapToolbarEnabled'] ?? false;
  options.fullscreenControl = optionsUpdate['mapToolbarEnabled'] ?? false;
  options.streetViewControl = false;

  return options;
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
  'administrative.country': gmaps.MapTypeStyleFeatureType.ADMINISTRATIVE_COUNTRY,
  'administrative.land_parcel': gmaps.MapTypeStyleFeatureType.ADMINISTRATIVE_LAND_PARCEL,
  'administrative.locality': gmaps.MapTypeStyleFeatureType.ADMINISTRATIVE_LOCALITY,
  'administrative.neighborhood': gmaps.MapTypeStyleFeatureType.ADMINISTRATIVE_NEIGHBORHOOD,
  'administrative.province': gmaps.MapTypeStyleFeatureType.ADMINISTRATIVE_PROVINCE,
  'all': gmaps.MapTypeStyleFeatureType.ALL,
  'landscape': gmaps.MapTypeStyleFeatureType.LANDSCAPE,
  'landscape.man_made': gmaps.MapTypeStyleFeatureType.LANDSCAPE_MAN_MADE,
  'landscape.natural': gmaps.MapTypeStyleFeatureType.LANDSCAPE_NATURAL,
  'landscape.natural.landcover': gmaps.MapTypeStyleFeatureType.LANDSCAPE_NATURAL_LANDCOVER,
  'landscape.natural.terrain': gmaps.MapTypeStyleFeatureType.LANDSCAPE_NATURAL_TERRAIN,
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
  'road.highway.controlled_access': gmaps.MapTypeStyleFeatureType.ROAD_HIGHWAY_CONTROLLED_ACCESS,
  'road.local': gmaps.MapTypeStyleFeatureType.ROAD_LOCAL,
  'transit': gmaps.MapTypeStyleFeatureType.TRANSIT,
  'transit.line': gmaps.MapTypeStyleFeatureType.TRANSIT_LINE,
  'transit.station': gmaps.MapTypeStyleFeatureType.TRANSIT_STATION,
  'transit.station.airport': gmaps.MapTypeStyleFeatureType.TRANSIT_STATION_AIRPORT,
  'transit.station.bus': gmaps.MapTypeStyleFeatureType.TRANSIT_STATION_BUS,
  'transit.station.rail': gmaps.MapTypeStyleFeatureType.TRANSIT_STATION_RAIL,
  'water': gmaps.MapTypeStyleFeatureType.WATER,
};

// The keys we'd expect to see in a serialized MapTypeStyle JSON object.
final _mapStyleKeys = {
  'elementType', 'featureType', 'stylers',
};

// Checks if the passed in Map contains some of the _mapStyleKeys.
bool _isJsonMapStyle(Map value) {
  return _mapStyleKeys.intersection(value.keys.toSet()).isNotEmpty;
}

// Converts an incoming JSON-encoded Style info, into the correct gmaps array.
List<gmaps.MapTypeStyle> _mapStyles(String mapStyleJson) {
  List<gmaps.MapTypeStyle> styles = [];
  if(mapStyleJson != null) {
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

PolylineUpdates _polylineFromParams(value) {
  if (value != null) {
    List<Map<String, dynamic>> list = value;
    Set<Polyline> current = Set<Polyline>();
    list.forEach((polyline) {
      PolylineId polylineId = PolylineId(polyline['polylineId']);
      List<LatLng> points = [];
      List<dynamic> jsonPoints = polyline['points'];
      jsonPoints.forEach((p) {
        points.add(LatLng.fromJson(p));
      });
      current.add(
          Polyline(
            polylineId: polylineId,
            consumeTapEvents: polyline['consumeTapEvents'],
            color: Color(polyline['color']),
            geodesic: polyline['geodesic'],
            visible: polyline['visible'],
            zIndex: polyline['zIndex'],
            width: polyline['width'],
            points: points,
//            endCap = Cap.buttCap,
//            jointType = JointType.mitered,
//            patterns = const <PatternItem>[],
//            startCap = Cap.buttCap,
          )
      );
    });
    return PolylineUpdates.from(null, current);
  }
  return null;
}

gmaps.PolylineOptions _polylineOptionsFromPolyline(gmaps.GMap googleMap,
    Polyline polyline) {
  List<gmaps.LatLng> paths = [];
  polyline.points.forEach((point) {
    paths.add(_latlngToGmLatlng(point));
  });

  return gmaps.PolylineOptions()
    ..path = paths
    ..strokeOpacity = 1.0
    ..strokeWeight = polyline.width
    ..strokeColor =  '#'+polyline.color.value.toRadixString(16).substring(0,6)
    ..visible = polyline.visible
    ..zIndex = polyline.zIndex
    ..geodesic = polyline.geodesic
  ;
//  this.endCap = Cap.buttCap,
//  this.jointType = JointType.mitered,
//  this.patterns = const <PatternItem>[],
//  this.startCap = Cap.buttCap,
//  this.width = 10,
}


PolygonUpdates _polygonFromParams(value) {
  if (value != null) {
    List<Map<String, dynamic>> list = value;
    Set<Polygon> current = Set<Polygon>();
    list.forEach((polygon) {
      PolygonId polygonId = PolygonId(polygon['polygonId']);
      List<LatLng> points = [];
      List<dynamic> jsonPoints = polygon['points'];
      jsonPoints.forEach((p) {
        points.add(LatLng.fromJson(p));
      });
      current.add(
          Polygon(
            polygonId: polygonId,
            consumeTapEvents: polygon['consumeTapEvents'],
            fillColor: Color(polygon['fillColor']),
            geodesic: polygon['geodesic'],
            strokeColor: Color(polygon['strokeColor']),
            strokeWidth: polygon['strokeWidth'],
            visible: polygon['visible'],
            zIndex: polygon['zIndex'],
            points: points,
          )
      );
    });
    return PolygonUpdates.from(null, current);
  }
  return null;
}

gmaps.PolygonOptions _polygonOptionsFromPolygon(gmaps.GMap googleMap,
    Polygon polygon) {
  List<gmaps.LatLng> paths = [];
  polygon.points.forEach((point) {
    paths.add(_latlngToGmLatlng(point));
  });
  return gmaps.PolygonOptions()
    ..paths = paths
    ..strokeColor = '#'+polygon.strokeColor.value.toRadixString(16)
    ..strokeOpacity = 0.8
    ..strokeWeight = polygon.strokeWidth
    ..fillColor = '#'+polygon.fillColor.value.toRadixString(16)
    ..fillOpacity = 0.35
    ..visible = polygon.visible
    ..zIndex = polygon.zIndex
    ..geodesic = polygon.geodesic
  ;
}

gmaps.LatLng _latlngToGmLatlng(LatLng latLng){
  return gmaps.LatLng(latLng.latitude, latLng.longitude);
}

LatLng _gmLatlngToLatlng(gmaps.LatLng latLng){
  return LatLng(latLng.lat, latLng.lng);
}

LatLngBounds _gmLatLngBoundsTolatLngBounds(gmaps.LatLngBounds latLngBounds){
  return LatLngBounds(
    southwest: _gmLatlngToLatlng(latLngBounds.southWest),
    northeast: _gmLatlngToLatlng(latLngBounds.northEast),
  );
}

CameraPosition _gmViewportToCameraPosition(gmaps.GMap map) {
  return CameraPosition(
    target: _gmLatlngToLatlng(map.center),
    bearing: map.heading ?? 0,
    tilt: map.tilt,
    zoom: map.zoom.toDouble(),
  );
}

MarkerUpdates _markerFromParams(value) {
  if (value != null) {
    List<Map<String, dynamic>> list = value;
    Set<Marker> current = Set<Marker>();
    list.forEach((marker) {
      MarkerId markerId = MarkerId(marker['markerId']);
      Offset offset = Offset(
          (marker['anchor'][0]),
          (marker['anchor'][1]));
      current.add(
          Marker(
            markerId: markerId,
            alpha: marker['alpha'],
            anchor: offset,
            consumeTapEvents: marker['consumeTapEvents'],
            draggable: marker['draggable'],
            flat:  marker['flat'],
            icon: BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(
              title: marker['infoWindow']['title'] ?? '',
              snippet: marker['snippet'],
              anchor : offset,
            ),
            position: LatLng.fromJson(marker['position']),
            rotation: marker['rotation'],
            visible: marker['visible'],
            zIndex: marker['zIndex'],
          )
      );
    });
    return MarkerUpdates.from(null, current);
  }
  return null;
}

gmaps.InfoWindowOptions _infoWindowOPtionsFromMarker(Marker marker) {
  return gmaps.InfoWindowOptions()
    ..content = marker.infoWindow.snippet
    ..zIndex    = marker.zIndex
    ..position = gmaps.LatLng(
        marker.position.latitude,
        marker.position.longitude)
  ;
}

gmaps.MarkerOptions _markerOptionsFromMarker(gmaps.GMap googleMap,
    Marker marker) {

  final iconConfig = marker.icon.toJson();
  gmaps.Icon icon;

  if(iconConfig[0] == 'fromAssetImage') {
    icon = gmaps.Icon()
      ..url = iconConfig[1];
  }
  return gmaps.MarkerOptions()
    ..position  = gmaps.LatLng(marker.position.latitude,
        marker.position.longitude,)
    ..title     = marker.infoWindow.title
    ..zIndex    = marker.zIndex
    ..visible   = marker.visible
    ..opacity   = marker.alpha
    ..draggable = marker.draggable
    ..icon      = icon
    ..anchorPoint = gmaps.Point(marker.anchor.dx, marker.anchor.dy,);
    // Flat and Rotation are not supported directly on the web.
}



gmaps.CircleOptions _circleOptionsFromCircle(Circle circle) {
  final populationOptions = gmaps.CircleOptions()
    ..strokeColor = '#'+circle.strokeColor.value.toRadixString(16)
    ..strokeOpacity = 0.8
    ..strokeWeight = circle.strokeWidth
    ..fillColor = '#'+circle.fillColor.value.toRadixString(16)
    ..fillOpacity = 0.6
    ..center = gmaps.LatLng(circle.center.latitude,circle.center.longitude)
    ..radius = circle.radius
    ..visible = circle.visible
  ;
  return populationOptions;
}

CircleUpdates _circleFromParams(value) {
  if (value != null) {
    List<Map<String, dynamic>> list = value;
    Set<Circle> current = Set<Circle>();
    list.forEach((circle) {
      CircleId circleId = CircleId(circle['circleId']);
      current.add(
          Circle(
            circleId: circleId,
            consumeTapEvents: circle['consumeTapEvents'],
            fillColor: Color(circle['fillColor']),
            center: LatLng.fromJson(circle['center']),
            radius: circle['radius'],
            strokeColor: Color(circle['strokeColor']),
            strokeWidth: circle['strokeWidth'],
            visible: circle['visible'],
            zIndex: circle['zIndex'],
          )
      );
    });
    return CircleUpdates.from(null, current);
  }
  return null;
}