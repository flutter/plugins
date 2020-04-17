part of google_maps_flutter_web;

void _optionsFromParams(GoogleMap.MapOptions options,
    Map<String, dynamic> optionsUpdate) {
  print('>'+ optionsUpdate.toString());
//      compassEnabled: true
//      mapToolbarEnabled: true
//      cameraTargetBounds: [null]
//      mapType: 1
//  ..mapTypeId(optionsUpdate['mapType'])
//      minMaxZoomPreference: [null
//        null]
//      rotateGesturesEnabled: true
//      scrollGesturesEnabled: true
//      tiltGesturesEnabled: true
//      zoomGesturesEnabled: true
//      trackCameraPosition: true
//      myLocationEnabled: true
//      myLocationButtonEnabled: true
//      padding: [0
//        0
//        0
//        0]
//      indoorEnabled: true
//      trafficEnabled: false
//      buildingsEnabled: true
      ;
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

  dynamic iconConfig = marker.icon.toJson();
  dynamic icon;

  if(iconConfig[0] == 'defaultMarker') icon = '';
  else if(iconConfig[0] == 'fromAssetImage') {
    print('TODO:' + iconConfig);
    Image mImage = Image.asset(iconConfig[1] );
//    ui.Image image = mImage.;
  }
  return GoogleMap.MarkerOptions()
    ..position  = GoogleMap.LatLng(marker.position.latitude,
        marker.position.longitude)
    ..title     = marker.infoWindow.title
    ..zIndex    = marker.zIndex
    ..visible   = marker.visible
    ..opacity   = marker.alpha
    ..draggable = marker.draggable
    ..icon      = icon//  this.icon = BitmapDescriptor.defaultMarker,
    ..anchorPoint = GoogleMap.Point(marker.anchor.dx, marker.anchor.dy)
  //marker.rotation
  //https://stackoverflow.com/questions/6800613/rotating-image-marker-image-on-google-map-v3/28819037
//  this.flat = false,
      ;
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