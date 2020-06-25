part of google_maps_flutter_web;

void _optionsFromParams(GoogleMap.MapOptions options,
    Map<String, dynamic> optionsUpdate) {
  if(optionsUpdate['mapType'] != null) {
    options
      ..mapTypeId = GoogleMap.MapTypeId.values[optionsUpdate['mapType']]
    ;}
  options
    ..minZoom   = optionsUpdate['minMaxZoomPreference'][0]
    ..maxZoom   = optionsUpdate['minMaxZoomPreference'][1]
  ;
//  compassEnabled,
//  mapToolbarEnabled,
//  cameraTargetBounds,
//  mapType,
//  minMaxZoomPreference,
//  rotateGesturesEnabled,
//  scrollGesturesEnabled,
//  tiltGesturesEnabled,
//  trackCameraPosition,
//  zoomGesturesEnabled,
//  myLocationEnabled,
//  myLocationButtonEnabled,
//  padding,
//  indoorViewEnabled,
//  trafficEnabled,
//  buildingsEnabled,

// backgroundColor(String _backgroundColor)
//center(LatLng _center)
//clickableIcons(bool _clickableIcons)
//disableDefaultUI(bool _disableDefaultUI)
//disableDoubleClickZoom(bool _disableDoubleClickZoom)
//draggable(bool _draggable)
//draggableCursor(String _draggableCursor)
//draggingCursor(String _draggingCursor)
//fullscreenControl(bool _fullscreenControl)
//fullscreenControlOptions(
//gestureHandling(String _gestureHandling)
//heading(num _heading)
//keyboardShortcuts(bool _keyboardShortcuts)
//mapTypeControl(bool _mapTypeControl)
//mapTypeControlOptions(MapTypeControlOptions _mapTypeControlOptions)
//_mapTypeId(dynamic __mapTypeId)
//mapTypeId(dynamic /*MapTypeId|String*/ mapTypeId)
//maxZoom(num _maxZoom)
//minZoom(num _minZoom)
//noClear(bool _noClear)
//overviewMapControl(bool _overviewMapControl)
//overviewMapControlOptions(
//panControl(bool _panControl)
//panControlOptions(PanControlOptions _panControlOptions)
//rotateControl(bool _rotateControl)
//rotateControlOptions(RotateControlOptions _rotateControlOptions)
//scaleControl(bool _scaleControl)
//scaleControlOptions(ScaleControlOptions _scaleControlOptions)
//scrollwheel(bool _scrollwheel)
//streetView(StreetViewPanorama _streetView)
//streetViewControl(bool _streetViewControl)
//streetViewControlOptions(
//styles(List<MapTypeStyle> _styles)
//tilt(num _tilt)
//zoom(num _zoom)
//zoomControl(bool _zoomControl)
//zoomControlOptions(ZoomControlOptions _zoomControlOptions)
}

List<GoogleMap.MapTypeStyle> _mapStyles(String mapStyle) {
  List<GoogleMap.MapTypeStyle> styles = [];
  if(mapStyle != null) {
    List list = json.decode(mapStyle);
    list.forEach((style) {
      List list2 = style['stylers'];
      List<GoogleMap.MapTypeStyler> stylers = [];
      list2.forEach((style) {
        stylers.add(
            GoogleMap.MapTypeStyler()
              ..color = style['color']
              ..gamma = style['gamma']
              ..hue = style['hue']
              ..invertLightness = style['invertLightness']
              ..lightness = style['lightness']
              ..saturation = style['saturation']
              ..visibility = style['visibility']
              ..weight = style['weight']
        );
      });

      GoogleMap.MapTypeStyleElementType elementType;
      if (style['elementType'] == 'geometry') {
        elementType = GoogleMap.MapTypeStyleElementType.GEOMETRY;
      } else if (style['elementType'] == 'geometry.fill') {
        elementType = GoogleMap.MapTypeStyleElementType.GEOMETRY_FILL;
      } else if (style['elementType'] == 'geometry.stroke') {
        elementType = GoogleMap.MapTypeStyleElementType.GEOMETRY_STROKE;
      } else if (style['elementType'] == 'labels') {
        elementType = GoogleMap.MapTypeStyleElementType.LABELS;
      } else if (style['elementType'] == 'labels.icon') {
        elementType = GoogleMap.MapTypeStyleElementType.LABELS_ICON;
      } else if (style['elementType'] == 'labels.text') {
        elementType = GoogleMap.MapTypeStyleElementType.LABELS_TEXT;
      } else if (style['elementType'] == 'labels.text.fill') {
        elementType = GoogleMap.MapTypeStyleElementType.LABELS_TEXT_FILL;
      } else if (style['elementType'] == 'labels.text.stroke') {
        elementType = GoogleMap.MapTypeStyleElementType.LABELS_TEXT_STROKE;
      }

      GoogleMap.MapTypeStyleFeatureType featureType;
      if (style[featureType] == 'administrative') {
        featureType = GoogleMap.MapTypeStyleFeatureType.ADMINISTRATIVE;
      }
      else if (style[featureType] == 'administrative.country') {
        featureType = GoogleMap.MapTypeStyleFeatureType.ADMINISTRATIVE_COUNTRY;
      }
      else if (style[featureType] == 'administrative.land_parcel') {
        featureType =
            GoogleMap.MapTypeStyleFeatureType.ADMINISTRATIVE_LAND_PARCEL;
      }
      else if (style[featureType] == 'administrative.locality') {
        featureType = GoogleMap.MapTypeStyleFeatureType.ADMINISTRATIVE_LOCALITY;
      }
      else if (style[featureType] == 'administrative.neighborhood') {
        featureType =
            GoogleMap.MapTypeStyleFeatureType.ADMINISTRATIVE_NEIGHBORHOOD;
      }
      else if (style[featureType] == 'administrative.province') {
        featureType = GoogleMap.MapTypeStyleFeatureType.ADMINISTRATIVE_PROVINCE;
      }
      else if (style[featureType] == 'all') {
        featureType = GoogleMap.MapTypeStyleFeatureType.ALL;
      }
      else if (style[featureType] == 'landscape') {
        featureType = GoogleMap.MapTypeStyleFeatureType.LANDSCAPE;
      }
      else if (style[featureType] == 'landscape.man_made') {
        featureType = GoogleMap.MapTypeStyleFeatureType.LANDSCAPE_MAN_MADE;
      }
      else if (style[featureType] == 'landscape.natural') {
        featureType = GoogleMap.MapTypeStyleFeatureType.LANDSCAPE_NATURAL;
      }
      else if (style[featureType] == 'landscape.natural.landcover') {
        featureType =
            GoogleMap.MapTypeStyleFeatureType.LANDSCAPE_NATURAL_LANDCOVER;
      }
      else if (style[featureType] == 'landscape.natural.terrain') {
        featureType =
            GoogleMap.MapTypeStyleFeatureType.LANDSCAPE_NATURAL_TERRAIN;
      }
      else if (style[featureType] == 'poi') {
        featureType = GoogleMap.MapTypeStyleFeatureType.POI;
      }
      else if (style[featureType] == 'poi.attraction') {
        featureType = GoogleMap.MapTypeStyleFeatureType.POI_ATTRACTION;
      }
      else if (style[featureType] == 'poi.business') {
        featureType = GoogleMap.MapTypeStyleFeatureType.POI_BUSINESS;
      }
      else if (style[featureType] == 'poi.government') {
        featureType = GoogleMap.MapTypeStyleFeatureType.POI_GOVERNMENT;
      }
      else if (style[featureType] == 'poi.medical') {
        featureType = GoogleMap.MapTypeStyleFeatureType.POI_MEDICAL;
      }
      else if (style[featureType] == 'poi.park') {
        featureType = GoogleMap.MapTypeStyleFeatureType.POI_PARK;
      }
      else if (style[featureType] == 'poi.place_of_worship') {
        featureType = GoogleMap.MapTypeStyleFeatureType.POI_PLACE_OF_WORSHIP;
      }
      else if (style[featureType] == 'poi.school') {
        featureType = GoogleMap.MapTypeStyleFeatureType.POI_SCHOOL;
      }
      else if (style[featureType] == 'poi.sports_complex') {
        featureType = GoogleMap.MapTypeStyleFeatureType.POI_SPORTS_COMPLEX;
      }
      else if (style[featureType] == 'road') {
        featureType = GoogleMap.MapTypeStyleFeatureType.ROAD;
      }
      else if (style[featureType] == 'road.arterial') {
        featureType = GoogleMap.MapTypeStyleFeatureType.ROAD_ARTERIAL;
      }
      else if (style[featureType] == 'road.highway') {
        featureType = GoogleMap.MapTypeStyleFeatureType.ROAD_HIGHWAY;
      }
      else if (style[featureType] == 'road.highway.controlled_access') {
        featureType =
            GoogleMap.MapTypeStyleFeatureType.ROAD_HIGHWAY_CONTROLLED_ACCESS;
      }
      else if (style[featureType] == 'road.local') {
        featureType = GoogleMap.MapTypeStyleFeatureType.ROAD_LOCAL;
      }
      else if (style[featureType] == 'transit') {
        featureType = GoogleMap.MapTypeStyleFeatureType.TRANSIT;
      }
      else if (style[featureType] == 'transit.line') {
        featureType = GoogleMap.MapTypeStyleFeatureType.TRANSIT_LINE;
      }
      else if (style[featureType] == 'transit.station') {
        featureType = GoogleMap.MapTypeStyleFeatureType.TRANSIT_STATION;
      }
      else if (style[featureType] == 'transit.station.airport') {
        featureType = GoogleMap.MapTypeStyleFeatureType.TRANSIT_STATION_AIRPORT;
      }
      else if (style[featureType] == 'transit.station.bus') {
        featureType = GoogleMap.MapTypeStyleFeatureType.TRANSIT_STATION_BUS;
      }
      else if (style[featureType] == 'transit.station.rail') {
        featureType = GoogleMap.MapTypeStyleFeatureType.TRANSIT_STATION_RAIL;
      }
      else if (style[featureType] == 'water') {
        featureType = GoogleMap.MapTypeStyleFeatureType.WATER;
      }

      styles.add(
          GoogleMap.MapTypeStyle()
            ..elementType = elementType
            ..featureType = featureType
            ..stylers = stylers
      );
    });
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

GoogleMap.PolylineOptions _polylineOptionsFromPolyline(GoogleMap.GMap googleMap,
    Polyline polyline) {
  List<GoogleMap.LatLng> paths = [];
  polyline.points.forEach((point) {
    paths.add(_latlngToGmLatlng(point));
  });

  return GoogleMap.PolylineOptions()
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

GoogleMap.PolygonOptions _polygonOptionsFromPolygon(GoogleMap.GMap googleMap,
    Polygon polygon) {
  List<GoogleMap.LatLng> paths = [];
  polygon.points.forEach((point) {
    paths.add(_latlngToGmLatlng(point));
  });
  return GoogleMap.PolygonOptions()
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

GoogleMap.LatLng _latlngToGmLatlng(LatLng latLng){
  return GoogleMap.LatLng(latLng.latitude, latLng.longitude);
}

LatLng _gmLatlngToLatlng(GoogleMap.LatLng latLng){
  return LatLng(latLng.lat, latLng.lng);
}

LatLngBounds _gmLatLngBoundsTolatLngBounds(GoogleMap.LatLngBounds latLngBounds){
  return LatLngBounds(
    southwest: _gmLatlngToLatlng(latLngBounds.southWest),
    northeast: _gmLatlngToLatlng(latLngBounds.northEast),
  );
}

CameraPosition _gmViewportToCameraPosition(GoogleMap.GMap map) {
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

GoogleMap.InfoWindowOptions _infoWindowOPtionsFromMarker(Marker marker) {
  return GoogleMap.InfoWindowOptions()
    ..content = marker.infoWindow.snippet
    ..zIndex    = marker.zIndex
    ..position = GoogleMap.LatLng(
        marker.position.latitude,
        marker.position.longitude)
  ;
}

GoogleMap.MarkerOptions _markerOptionsFromMarker(GoogleMap.GMap googleMap,
    Marker marker) {

  final iconConfig = marker.icon.toJson();
  GoogleMap.Icon icon;

  if(iconConfig[0] == 'fromAssetImage') {
    icon = GoogleMap.Icon()
      ..url = iconConfig[1];
  }
  return GoogleMap.MarkerOptions()
    ..position  = GoogleMap.LatLng(marker.position.latitude,
        marker.position.longitude,)
    ..title     = marker.infoWindow.title
    ..zIndex    = marker.zIndex
    ..visible   = marker.visible
    ..opacity   = marker.alpha
    ..draggable = marker.draggable
    ..icon      = icon
    ..anchorPoint = GoogleMap.Point(marker.anchor.dx, marker.anchor.dy,);
    // Flat and Rotation are not supported directly on the web.
}



GoogleMap.CircleOptions _circleOptionsFromCircle(Circle circle) {
  final populationOptions = GoogleMap.CircleOptions()
    ..strokeColor = '#'+circle.strokeColor.value.toRadixString(16)
    ..strokeOpacity = 0.8
    ..strokeWeight = circle.strokeWidth
    ..fillColor = '#'+circle.fillColor.value.toRadixString(16)
    ..fillOpacity = 0.6
    ..center = GoogleMap.LatLng(circle.center.latitude,circle.center.longitude)
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