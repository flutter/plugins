// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Mocks generated by Mockito 5.0.1 from annotations
// in google_maps_flutter_web_integration_tests/integration_test/google_maps_plugin_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i5;

import 'package:google_maps_flutter_platform_interface/src/events/map_event.dart'
    as _i6;
import 'package:google_maps_flutter_platform_interface/src/types/camera.dart'
    as _i7;
import 'package:google_maps_flutter_platform_interface/src/types/circle_updates.dart'
    as _i8;
import 'package:google_maps_flutter_platform_interface/src/types/location.dart'
    as _i2;
import 'package:google_maps_flutter_platform_interface/src/types/marker.dart'
    as _i12;
import 'package:google_maps_flutter_platform_interface/src/types/marker_updates.dart'
    as _i11;
import 'package:google_maps_flutter_platform_interface/src/types/polygon_updates.dart'
    as _i9;
import 'package:google_maps_flutter_platform_interface/src/types/polyline_updates.dart'
    as _i10;
import 'package:google_maps_flutter_platform_interface/src/types/screen_coordinate.dart'
    as _i3;
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart' as _i4;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: comment_references
// ignore_for_file: unnecessary_parenthesis

class _FakeLatLngBounds extends _i1.Fake implements _i2.LatLngBounds {}

class _FakeScreenCoordinate extends _i1.Fake implements _i3.ScreenCoordinate {}

class _FakeLatLng extends _i1.Fake implements _i2.LatLng {}

/// A class which mocks [GoogleMapController].
///
/// See the documentation for Mockito's code generation for more information.
class MockGoogleMapController extends _i1.Mock
    implements _i4.GoogleMapController {
  @override
  _i5.Stream<_i6.MapEvent<dynamic>> get events =>
      (super.noSuchMethod(Invocation.getter(#events),
              returnValue: Stream<_i6.MapEvent<dynamic>>.empty())
          as _i5.Stream<_i6.MapEvent<dynamic>>);
  @override
  void updateRawOptions(Map<String, dynamic>? optionsUpdate) =>
      super.noSuchMethod(Invocation.method(#updateRawOptions, [optionsUpdate]),
          returnValueForMissingStub: null);
  @override
  _i5.Future<_i2.LatLngBounds> getVisibleRegion() =>
      (super.noSuchMethod(Invocation.method(#getVisibleRegion, []),
              returnValue: Future.value(_FakeLatLngBounds()))
          as _i5.Future<_i2.LatLngBounds>);
  @override
  _i5.Future<_i3.ScreenCoordinate> getScreenCoordinate(_i2.LatLng? latLng) =>
      (super.noSuchMethod(Invocation.method(#getScreenCoordinate, [latLng]),
              returnValue: Future.value(_FakeScreenCoordinate()))
          as _i5.Future<_i3.ScreenCoordinate>);
  @override
  _i5.Future<_i2.LatLng> getLatLng(_i3.ScreenCoordinate? screenCoordinate) =>
      (super.noSuchMethod(Invocation.method(#getLatLng, [screenCoordinate]),
          returnValue: Future.value(_FakeLatLng())) as _i5.Future<_i2.LatLng>);
  @override
  _i5.Future<void> moveCamera(_i7.CameraUpdate? cameraUpdate) =>
      (super.noSuchMethod(Invocation.method(#moveCamera, [cameraUpdate]),
          returnValue: Future.value(null),
          returnValueForMissingStub: Future.value()) as _i5.Future<void>);
  @override
  _i5.Future<double> getZoomLevel() =>
      (super.noSuchMethod(Invocation.method(#getZoomLevel, []),
          returnValue: Future.value(0.0)) as _i5.Future<double>);
  @override
  void updateCircles(_i8.CircleUpdates? updates) =>
      super.noSuchMethod(Invocation.method(#updateCircles, [updates]),
          returnValueForMissingStub: null);
  @override
  void updatePolygons(_i9.PolygonUpdates? updates) =>
      super.noSuchMethod(Invocation.method(#updatePolygons, [updates]),
          returnValueForMissingStub: null);
  @override
  void updatePolylines(_i10.PolylineUpdates? updates) =>
      super.noSuchMethod(Invocation.method(#updatePolylines, [updates]),
          returnValueForMissingStub: null);
  @override
  void updateMarkers(_i11.MarkerUpdates? updates) =>
      super.noSuchMethod(Invocation.method(#updateMarkers, [updates]),
          returnValueForMissingStub: null);
  @override
  void showInfoWindow(_i12.MarkerId? markerId) =>
      super.noSuchMethod(Invocation.method(#showInfoWindow, [markerId]),
          returnValueForMissingStub: null);
  @override
  void hideInfoWindow(_i12.MarkerId? markerId) =>
      super.noSuchMethod(Invocation.method(#hideInfoWindow, [markerId]),
          returnValueForMissingStub: null);
  @override
  bool isInfoWindowShown(_i12.MarkerId? markerId) =>
      (super.noSuchMethod(Invocation.method(#isInfoWindowShown, [markerId]),
          returnValue: false) as bool);
}
