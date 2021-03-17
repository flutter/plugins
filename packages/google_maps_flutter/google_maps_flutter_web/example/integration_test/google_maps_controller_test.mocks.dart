// Mocks generated by Mockito 5.0.1 from annotations
// in google_maps_flutter_web_integration_tests/integration_test/google_maps_controller_test.dart.
// Do not manually edit this file.

import 'package:google_maps/src/generated/google_maps_core.js.g.dart' as _i2;
import 'package:google_maps_flutter_platform_interface/src/types/circle.dart'
    as _i4;
import 'package:google_maps_flutter_platform_interface/src/types/marker.dart'
    as _i7;
import 'package:google_maps_flutter_platform_interface/src/types/polygon.dart'
    as _i5;
import 'package:google_maps_flutter_platform_interface/src/types/polyline.dart'
    as _i6;
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart' as _i3;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: comment_references
// ignore_for_file: unnecessary_parenthesis

class _FakeGMap extends _i1.Fake implements _i2.GMap {}

/// A class which mocks [CirclesController].
///
/// See the documentation for Mockito's code generation for more information.
class MockCirclesController extends _i1.Mock implements _i3.CirclesController {
  @override
  Map<_i4.CircleId, _i3.CircleController> get circles =>
      (super.noSuchMethod(Invocation.getter(#circles),
              returnValue: <_i4.CircleId, _i3.CircleController>{})
          as Map<_i4.CircleId, _i3.CircleController>);
  @override
  _i2.GMap get googleMap => (super.noSuchMethod(Invocation.getter(#googleMap),
      returnValue: _FakeGMap()) as _i2.GMap);
  @override
  set googleMap(_i2.GMap? _googleMap) =>
      super.noSuchMethod(Invocation.setter(#googleMap, _googleMap),
          returnValueForMissingStub: null);
  @override
  int get mapId =>
      (super.noSuchMethod(Invocation.getter(#mapId), returnValue: 0) as int);
  @override
  set mapId(int? _mapId) =>
      super.noSuchMethod(Invocation.setter(#mapId, _mapId),
          returnValueForMissingStub: null);
  @override
  void addCircles(Set<_i4.Circle>? circlesToAdd) =>
      super.noSuchMethod(Invocation.method(#addCircles, [circlesToAdd]),
          returnValueForMissingStub: null);
  @override
  void changeCircles(Set<_i4.Circle>? circlesToChange) =>
      super.noSuchMethod(Invocation.method(#changeCircles, [circlesToChange]),
          returnValueForMissingStub: null);
  @override
  void removeCircles(Set<_i4.CircleId>? circleIdsToRemove) =>
      super.noSuchMethod(Invocation.method(#removeCircles, [circleIdsToRemove]),
          returnValueForMissingStub: null);
  @override
  void bindToMap(int? mapId, _i2.GMap? googleMap) =>
      super.noSuchMethod(Invocation.method(#bindToMap, [mapId, googleMap]),
          returnValueForMissingStub: null);
}

/// A class which mocks [PolygonsController].
///
/// See the documentation for Mockito's code generation for more information.
class MockPolygonsController extends _i1.Mock
    implements _i3.PolygonsController {
  @override
  Map<_i5.PolygonId, _i3.PolygonController> get polygons =>
      (super.noSuchMethod(Invocation.getter(#polygons),
              returnValue: <_i5.PolygonId, _i3.PolygonController>{})
          as Map<_i5.PolygonId, _i3.PolygonController>);
  @override
  _i2.GMap get googleMap => (super.noSuchMethod(Invocation.getter(#googleMap),
      returnValue: _FakeGMap()) as _i2.GMap);
  @override
  set googleMap(_i2.GMap? _googleMap) =>
      super.noSuchMethod(Invocation.setter(#googleMap, _googleMap),
          returnValueForMissingStub: null);
  @override
  int get mapId =>
      (super.noSuchMethod(Invocation.getter(#mapId), returnValue: 0) as int);
  @override
  set mapId(int? _mapId) =>
      super.noSuchMethod(Invocation.setter(#mapId, _mapId),
          returnValueForMissingStub: null);
  @override
  void addPolygons(Set<_i5.Polygon>? polygonsToAdd) =>
      super.noSuchMethod(Invocation.method(#addPolygons, [polygonsToAdd]),
          returnValueForMissingStub: null);
  @override
  void changePolygons(Set<_i5.Polygon>? polygonsToChange) =>
      super.noSuchMethod(Invocation.method(#changePolygons, [polygonsToChange]),
          returnValueForMissingStub: null);
  @override
  void removePolygons(Set<_i5.PolygonId>? polygonIdsToRemove) => super
      .noSuchMethod(Invocation.method(#removePolygons, [polygonIdsToRemove]),
          returnValueForMissingStub: null);
  @override
  void bindToMap(int? mapId, _i2.GMap? googleMap) =>
      super.noSuchMethod(Invocation.method(#bindToMap, [mapId, googleMap]),
          returnValueForMissingStub: null);
}

/// A class which mocks [PolylinesController].
///
/// See the documentation for Mockito's code generation for more information.
class MockPolylinesController extends _i1.Mock
    implements _i3.PolylinesController {
  @override
  Map<_i6.PolylineId, _i3.PolylineController> get lines =>
      (super.noSuchMethod(Invocation.getter(#lines),
              returnValue: <_i6.PolylineId, _i3.PolylineController>{})
          as Map<_i6.PolylineId, _i3.PolylineController>);
  @override
  _i2.GMap get googleMap => (super.noSuchMethod(Invocation.getter(#googleMap),
      returnValue: _FakeGMap()) as _i2.GMap);
  @override
  set googleMap(_i2.GMap? _googleMap) =>
      super.noSuchMethod(Invocation.setter(#googleMap, _googleMap),
          returnValueForMissingStub: null);
  @override
  int get mapId =>
      (super.noSuchMethod(Invocation.getter(#mapId), returnValue: 0) as int);
  @override
  set mapId(int? _mapId) =>
      super.noSuchMethod(Invocation.setter(#mapId, _mapId),
          returnValueForMissingStub: null);
  @override
  void addPolylines(Set<_i6.Polyline>? polylinesToAdd) =>
      super.noSuchMethod(Invocation.method(#addPolylines, [polylinesToAdd]),
          returnValueForMissingStub: null);
  @override
  void changePolylines(Set<_i6.Polyline>? polylinesToChange) => super
      .noSuchMethod(Invocation.method(#changePolylines, [polylinesToChange]),
          returnValueForMissingStub: null);
  @override
  void removePolylines(Set<_i6.PolylineId>? polylineIdsToRemove) => super
      .noSuchMethod(Invocation.method(#removePolylines, [polylineIdsToRemove]),
          returnValueForMissingStub: null);
  @override
  void bindToMap(int? mapId, _i2.GMap? googleMap) =>
      super.noSuchMethod(Invocation.method(#bindToMap, [mapId, googleMap]),
          returnValueForMissingStub: null);
}

/// A class which mocks [MarkersController].
///
/// See the documentation for Mockito's code generation for more information.
class MockMarkersController extends _i1.Mock implements _i3.MarkersController {
  @override
  Map<_i7.MarkerId, _i3.MarkerController> get markers =>
      (super.noSuchMethod(Invocation.getter(#markers),
              returnValue: <_i7.MarkerId, _i3.MarkerController>{})
          as Map<_i7.MarkerId, _i3.MarkerController>);
  @override
  _i2.GMap get googleMap => (super.noSuchMethod(Invocation.getter(#googleMap),
      returnValue: _FakeGMap()) as _i2.GMap);
  @override
  set googleMap(_i2.GMap? _googleMap) =>
      super.noSuchMethod(Invocation.setter(#googleMap, _googleMap),
          returnValueForMissingStub: null);
  @override
  int get mapId =>
      (super.noSuchMethod(Invocation.getter(#mapId), returnValue: 0) as int);
  @override
  set mapId(int? _mapId) =>
      super.noSuchMethod(Invocation.setter(#mapId, _mapId),
          returnValueForMissingStub: null);
  @override
  void addMarkers(Set<_i7.Marker>? markersToAdd) =>
      super.noSuchMethod(Invocation.method(#addMarkers, [markersToAdd]),
          returnValueForMissingStub: null);
  @override
  void changeMarkers(Set<_i7.Marker>? markersToChange) =>
      super.noSuchMethod(Invocation.method(#changeMarkers, [markersToChange]),
          returnValueForMissingStub: null);
  @override
  void removeMarkers(Set<_i7.MarkerId>? markerIdsToRemove) =>
      super.noSuchMethod(Invocation.method(#removeMarkers, [markerIdsToRemove]),
          returnValueForMissingStub: null);
  @override
  void showMarkerInfoWindow(_i7.MarkerId? markerId) =>
      super.noSuchMethod(Invocation.method(#showMarkerInfoWindow, [markerId]),
          returnValueForMissingStub: null);
  @override
  void hideMarkerInfoWindow(_i7.MarkerId? markerId) =>
      super.noSuchMethod(Invocation.method(#hideMarkerInfoWindow, [markerId]),
          returnValueForMissingStub: null);
  @override
  bool isInfoWindowShown(_i7.MarkerId? markerId) =>
      (super.noSuchMethod(Invocation.method(#isInfoWindowShown, [markerId]),
          returnValue: false) as bool);
  @override
  void bindToMap(int? mapId, _i2.GMap? googleMap) =>
      super.noSuchMethod(Invocation.method(#bindToMap, [mapId, googleMap]),
          returnValueForMissingStub: null);
}
