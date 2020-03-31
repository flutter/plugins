import 'dart:async';
import 'dart:html';
import 'dart:ui' as ui;
import 'dart:math' show sqrt;

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';

import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:google_maps/google_maps.dart' as gm;
//import 'package:js/js.dart';

/// The web implementation of [GoogleMapsFlutterPlatform].
///
/// This class implements the `package:google_maps_flutter` functionality for the web.
class GoogleMapsPlugin extends GoogleMapsFlutterPlatform {

  /// Registers this class as the default instance of [GoogleMapsFlutterPlatform].
  static void registerWith(Registrar registrar) {
    GoogleMapsFlutterPlatform.instance = GoogleMapsPlugin();
  }

  static Future<String> get platformVersion async {
    return "1.0";
  }

  int _id = 0 ;
  List<GMap> _mapList = List<GMap>();

  @override
  Future<void> init(int mapId) {
  }

  @override
  Future<void> updateMapOptions(
      Map<String, dynamic> optionsUpdate, {
        @required int mapId,
      }) {
//    throw UnimplementedError('updateMapOptions() has not been implemented.');
  }

  @override
  Future<void> updateMarkers(
      MarkerUpdates markerUpdates, {
        @required int mapId,
      }) {
    throw UnimplementedError('updateMarkers() has not been implemented.');
  }

  @override
  Future<void> updatePolygons(
      PolygonUpdates polygonUpdates, {
        @required int mapId,
      }) {
    throw UnimplementedError('updatePolygons() has not been implemented.');
  }

  @override
  Future<void> updatePolylines(
      PolylineUpdates polylineUpdates, {
        @required int mapId,
      }) {
    throw UnimplementedError('updatePolylines() has not been implemented.');
  }

  @override
  Future<void> updateCircles(
      CircleUpdates circleUpdates, {
        @required int mapId,
      }) {
    throw UnimplementedError('updateCircles() has not been implemented.');
  }

  @override
  Future<void> animateCamera(
      CameraUpdate cameraUpdate, {
        @required int mapId,
      }) {
    throw UnimplementedError('animateCamera() has not been implemented.');
  }

  @override
  Future<void> moveCamera(
      CameraUpdate cameraUpdate, {
        @required int mapId,
      }) {
    throw UnimplementedError('moveCamera() has not been implemented.');
  }

  @override
  Future<void> setMapStyle(
      String mapStyle, {
        @required int mapId,
      }) {
    throw UnimplementedError('setMapStyle() has not been implemented.');
  }

  @override
  Future<LatLngBounds> getVisibleRegion({
    @required int mapId,
  }) {
    throw UnimplementedError('getVisibleRegion() has not been implemented.');
  }

  @override
  Future<ScreenCoordinate> getScreenCoordinate(
      LatLng latLng, {
        @required int mapId,
      }) {
    throw UnimplementedError('getScreenCoordinate() has not been implemented.');
  }

  @override
  Future<LatLng> getLatLng(
      ScreenCoordinate screenCoordinate, {
        @required int mapId,
      }) {
    throw UnimplementedError('getLatLng() has not been implemented.');
  }

  @override
  Future<void> showMarkerInfoWindow(
      MarkerId markerId, {
        @required int mapId,
      }) {
    throw UnimplementedError(
        'showMarkerInfoWindow() has not been implemented.');
  }

  @override
  Future<void> hideMarkerInfoWindow(
      MarkerId markerId, {
        @required int mapId,
      }) {
    throw UnimplementedError(
        'hideMarkerInfoWindow() has not been implemented.');
  }

  @override
  Future<bool> isMarkerInfoWindowShown(
      MarkerId markerId, {
        @required int mapId,
      }) {
    throw UnimplementedError('updateMapOptions() has not been implemented.');
  }

  @override
  Future<double> getZoomLevel({
    @required int mapId,
  }) {
    throw UnimplementedError('getZoomLevel() has not been implemented.');
  }

  // The following are the 11 possible streams of data from the native side
  // into the plugin

  @override
  Stream<CameraMoveStartedEvent> onCameraMoveStarted({@required int mapId}) {
    throw UnimplementedError('onCameraMoveStarted() has not been implemented.');
  }

  @override
  Stream<CameraMoveEvent> onCameraMove({@required int mapId}) {
    throw UnimplementedError('onCameraMove() has not been implemented.');
  }

  @override
  Stream<CameraIdleEvent> onCameraIdle({@required int mapId}) {
    throw UnimplementedError('onCameraMove() has not been implemented.');
  }

  @override
  Stream<MarkerTapEvent> onMarkerTap({@required int mapId}) {
    throw UnimplementedError('onMarkerTap() has not been implemented.');
  }

  @override
  Stream<InfoWindowTapEvent> onInfoWindowTap({@required int mapId}) {
    throw UnimplementedError('onInfoWindowTap() has not been implemented.');
  }

  @override
  Stream<MarkerDragEndEvent> onMarkerDragEnd({@required int mapId}) {
    throw UnimplementedError('onMarkerDragEnd() has not been implemented.');
  }

  @override
  Stream<PolylineTapEvent> onPolylineTap({@required int mapId}) {
    throw UnimplementedError('onPolylineTap() has not been implemented.');
  }

  @override
  Stream<PolygonTapEvent> onPolygonTap({@required int mapId}) {
    throw UnimplementedError('onPolygonTap() has not been implemented.');
  }

  @override
  Stream<CircleTapEvent> onCircleTap({@required int mapId}) {
    throw UnimplementedError('onCircleTap() has not been implemented.');
  }

  @override
  Stream<MapTapEvent> onTap({@required int mapId}) {
    throw UnimplementedError('onTap() has not been implemented.');
  }

  @override
  Stream<MapLongPressEvent> onLongPress({@required int mapId}) {
    throw UnimplementedError('onLongPress() has not been implemented.');
  }

  @override
  Widget buildView(
      Map<String, dynamic> creationParams,
      Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers,
      PlatformViewCreatedCallback onPlatformViewCreated) {

    gm.MapOptions options;
    DivElement div;

    List<Map<String, dynamic>> circlesToAdd= null;

    creationParams.forEach((key, value) {
      if(key == 'options')              updateMapOptions(value);
//      else if(key == 'markersToAdd')    updateMarkers(value);
//      else if(key == 'polygonsToAdd')   updatePolygons(value);
//      else if(key == 'polylinesToAdd')  updatePolylines(value);

      else if(key == 'circlesToAdd')    {
        circlesToAdd = value;
//        List<Map<String, dynamic>> list = value;
//        Set<Circle> current = Set<Circle> ();
//        list.forEach((circle) {
//          current.add(
//              Circle(
//                  circleId: CircleId( circle['circleId'] ),
//                  consumeTapEvents:circle['consumeTapEvents'],
//                  fillColor:Color(circle['fillColor']),
//                  center:LatLng.fromJson(circle['center']),
//                  radius:circle['radius'],
//                  strokeColor:Color(circle['strokeColor']),
//                  strokeWidth:circle['strokeWidth'],
//                  visible:circle['visible'],
//                  zIndex:circle['zIndex']
//              )
//          );
//        });
//        updateCircles(CircleUpdates.from(null, current));

      } else if(key == 'initialCameraPosition') {
        print('initialCameraPosition => $value');
        CameraPosition cameraPos = CameraPosition.fromMap(value);
        print(cameraPos.target.latitude);
        options = gm.MapOptions()
          ..zoom = cameraPos.zoom
          ..center = gm.LatLng(
              cameraPos.target.latitude,
              cameraPos.target.longitude
          )
        ;
      } else {
        print('un-handle >>$key');
      }
    }
    );

    int id=_id++;
    div = DivElement()
      ..id = 'plugins.flutter.io/google_maps_$id'
    ;
    ui.platformViewRegistry.registerViewFactory(
      'plugins.flutter.io/google_maps_$id',
          (int viewId) => div,
    );
    HtmlElementView html = HtmlElementView(viewType: 'plugins.flutter.io/google_maps_$id');
    _mapList.add(GMap(html, gm.GMap(div, options)));


    ///TODO move to updateCircles
    if(circlesToAdd != null) {
      circlesToAdd.forEach((circle) {
        Circle c = Circle(
            circleId: CircleId( circle['circleId'] ),
            consumeTapEvents:circle['consumeTapEvents'],
            fillColor:Color(circle['fillColor']),
            center:LatLng.fromJson(circle['center']),
            radius:circle['radius'],
            strokeColor:Color(circle['strokeColor']),
            strokeWidth:circle['strokeWidth'],
            visible:circle['visible'],
            zIndex:circle['zIndex']
        );
//https://github.com/cylyl/dart-google-maps/blob/master/example/05-drawing_on_map/circle-simple/page.dart
        final populationOptions = gm.CircleOptions()
          ..strokeColor = c.strokeColor.toString()
          ..strokeOpacity = 0.8
          ..strokeWeight = c.strokeWidth
          ..fillColor = c.fillColor.toString()
          ..fillOpacity = 0.35
          ..map = _mapList.elementAt(id).gmap
          ..center = gm.LatLng(c.center.latitude,c.center.longitude)
          ..radius = circle['radius']
        ;
        gm.Circle(populationOptions);

        });
    }
    return html;
  }

}

class GMap {
  final HtmlElementView html;
  final gm.GMap gmap;
  GMap(this.html,
      this.gmap);
}