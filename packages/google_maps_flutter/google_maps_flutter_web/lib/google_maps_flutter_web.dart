import 'dart:async';
import 'dart:html';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';

import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:google_maps/google_maps.dart';
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

  int _id ;
  HtmlElementView _mapView;
  MapOptions _mapOptions;
  DivElement _map;

  @override
  Future<void> init(int id) {
    _id = id;
    _map = DivElement()
      ..id = 'plugins.flutter.io/google_maps_$id'
//        ..style.width = "100%"
//        ..style.height = "100%"
//        ..style.border = 'none'
        ;
    _mapOptions = MapOptions()
      ..zoom = 8
      ..center = LatLng(-34.397, 150.644)
    ;
    GMap(_map, _mapOptions);
    ui.platformViewRegistry.registerViewFactory(
      'plugins.flutter.io/google_maps_$_id',
      (int viewId) => _map,
    );
  }

  @override
  void setMethodCallHandler(dynamic call) {
    throw UnimplementedError(
        'setMethodCallHandler() has not been implemented.');
  }

  @override
  Future<void> updateMapOptions(Map<String, dynamic> optionsUpdate) {
    throw UnimplementedError('updateMapOptions() has not been implemented.');
  }

  @override
	Future<void> updateMarkers(Map<String, dynamic> markerUpdates) {
    throw UnimplementedError('updateMarkers() has not been implemented.');
  }

  @override
	Future<void> updatePolygons(Map<String, dynamic> polygonUpdates) {
    throw UnimplementedError('updatePolygons() has not been implemented.');
  }

  @override
	Future<void> updatePolylines(Map<String, dynamic> polylineUpdates) {
    throw UnimplementedError('updatePolylines() has not been implemented.');
  }

  @override
	Future<void> updateCircles(Map<String, dynamic> circleUpdates) {
    throw UnimplementedError('updateCircles() has not been implemented.');
  }

  @override
	Future<void> animateCamera(dynamic cameraUpdate) {
    throw UnimplementedError('animateCamera() has not been implemented.');
  }

  @override
	Future<void> moveCamera(dynamic cameraUpdate) {
    throw UnimplementedError('moveCamera() has not been implemented.');
  }

  @override
	Future<void> setMapStyle(String mapStyle) {
    throw UnimplementedError('setMapStyle() has not been implemented.');
  }

  @override
	Future<Map<String, dynamic>> getVisibleRegion() {
    throw UnimplementedError('getVisibleRegion() has not been implemented.');
  }

  @override
	Future<List<dynamic>> getLatLng(dynamic latLng) {
    throw UnimplementedError('getLatLng() has not been implemented.');
  }

  @override
	Future<Map<String, int>> getScreenCoordinate(dynamic screenCoordinateInJson) {
    throw UnimplementedError('getScreenCoordinate() has not been implemented.');
  }

  @override
	Future<void> showMarkerInfoWindow(String markerId) {
    throw UnimplementedError(
        'showMarkerInfoWindow() has not been implemented.');
  }

  @override
	Future<void> hideMarkerInfoWindow(String markerId) {
    throw UnimplementedError(
        'hideMarkerInfoWindow() has not been implemented.');
  }

  @override
	Future<bool> isMarkerInfoWindowShown(String markerId) {
    throw UnimplementedError('updateMapOptions() has not been implemented.');
  }

  @override
	Future<double> getZoomLevel() {
    throw UnimplementedError('getZoomLevel() has not been implemented.');
  }

  @override
  Widget buildView(
      Map<String, dynamic> creationParams,
      Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers,
      PlatformViewCreatedCallback onPlatformViewCreated) {
      init(0);
      _mapView = HtmlElementView(viewType: 'plugins.flutter.io/google_maps_$_id');
    return _mapView;
  }

}
