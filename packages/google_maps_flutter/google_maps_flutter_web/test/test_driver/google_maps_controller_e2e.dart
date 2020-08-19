// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:e2e/e2e.dart';
import 'package:google_maps/google_maps.dart' as gmaps;
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

class _MockCirclesController extends Mock implements CirclesController {}

class _MockPolygonsController extends Mock implements PolygonsController {}

class _MockPolylinesController extends Mock implements PolylinesController {}

class _MockMarkersController extends Mock implements MarkersController {}

class _MockGMap extends Mock implements gmaps.GMap {
  final onClickController = StreamController<gmaps.MouseEvent>.broadcast();
  @override
  Stream<gmaps.MouseEvent> get onClick => onClickController.stream;

  final onRightclickController = StreamController<gmaps.MouseEvent>.broadcast();
  @override
  Stream<gmaps.MouseEvent> get onRightclick => onRightclickController.stream;

  final onBoundsChangedController = StreamController<dynamic>.broadcast();
  @override
  Stream<dynamic> get onBoundsChanged => onBoundsChangedController.stream;

  final onIdleController = StreamController<dynamic>.broadcast();
  @override
  Stream<dynamic> get onIdle => onIdleController.stream;
}

/// Test Google Map Controller
void main() {
  E2EWidgetsFlutterBinding.ensureInitialized() as E2EWidgetsFlutterBinding;

  group('GoogleMapController', () {
    final int mapId = 33930;
    GoogleMapController controller;
    StreamController<MapEvent> stream;

    // Creates a controller with the default mapId and stream controller, and any `options` needed.
    GoogleMapController _createController({Map<String, dynamic> options}) {
      return GoogleMapController(
          mapId: mapId,
          streamController: stream,
          rawOptions: options ?? <String, dynamic>{});
    }

    setUp(() {
      stream = StreamController<MapEvent>.broadcast();
    });

    group('construct/dispose', () {
      setUp(() {
        controller = _createController();
      });

      testWidgets('constructor creates widget', (WidgetTester tester) async {
        expect(controller.widget, isNotNull);
        expect(controller.widget.viewType, endsWith('$mapId'));
      });

      testWidgets('widget is cached when reused', (WidgetTester tester) async {
        final first = controller.widget;
        final again = controller.widget;
        expect(identical(first, again), isTrue);
      });

      testWidgets('dispose closes the stream and removes the widget',
          (WidgetTester tester) async {
        controller.dispose();
        expect(stream.isClosed, isTrue);
        expect(controller.widget, isNull);
      });
    });

    group('init', () {
      _MockCirclesController circles;
      _MockMarkersController markers;
      _MockPolygonsController polygons;
      _MockPolylinesController polylines;
      _MockGMap map;

      setUp(() {
        circles = _MockCirclesController();
        markers = _MockMarkersController();
        polygons = _MockPolygonsController();
        polylines = _MockPolylinesController();
        map = _MockGMap();
      });

      testWidgets('listens to map events', (WidgetTester tester) async {
        controller = _createController();
        controller.debugSetOverrides(
          createMap: (_, __) => map,
          circles: circles,
          markers: markers,
          polygons: polygons,
          polylines: polylines,
        );

        expect(map.onClickController.hasListener, isFalse);
        expect(map.onRightclickController.hasListener, isFalse);
        expect(map.onBoundsChangedController.hasListener, isFalse);
        expect(map.onIdleController.hasListener, isFalse);

        controller.init();

        expect(map.onClickController.hasListener, isTrue);
        expect(map.onRightclickController.hasListener, isTrue);
        expect(map.onBoundsChangedController.hasListener, isTrue);
        expect(map.onIdleController.hasListener, isTrue);
      });

      testWidgets('binds geometry controllers to map\'s',
          (WidgetTester tester) async {
        controller = _createController();
        controller.debugSetOverrides(
          createMap: (_, __) => map,
          circles: circles,
          markers: markers,
          polygons: polygons,
          polylines: polylines,
        );

        controller.init();

        verify(circles.bindToMap(mapId, map));
        verify(markers.bindToMap(mapId, map));
        verify(polygons.bindToMap(mapId, map));
        verify(polylines.bindToMap(mapId, map));
      });

      testWidgets('renders initial geometry', (WidgetTester tester) async {
        controller = _createController(options: {
          'circlesToAdd': [
            {'circleId': 'circle-1'}
          ],
          'markersToAdd': [
            {'markerId': 'marker-1'}
          ],
          'polygonsToAdd': [
            {'polygonId': 'polygon-1'}
          ],
          'polylinesToAdd': [
            {'polylineId': 'polyline-1'}
          ],
        });
        controller.debugSetOverrides(
          circles: circles,
          markers: markers,
          polygons: polygons,
          polylines: polylines,
        );

        controller.init();

        final capturedCircles =
            verify(circles.addCircles(captureAny)).captured[0] as Set<Circle>;
        final capturedMarkers =
            verify(markers.addMarkers(captureAny)).captured[0] as Set<Marker>;
        final capturedPolygons = verify(polygons.addPolygons(captureAny))
            .captured[0] as Set<Polygon>;
        final capturedPolylines = verify(polylines.addPolylines(captureAny))
            .captured[0] as Set<Polyline>;

        expect(capturedCircles.first.circleId.value, 'circle-1');
        expect(capturedMarkers.first.markerId.value, 'marker-1');
        expect(capturedPolygons.first.polygonId.value, 'polygon-1');
        expect(capturedPolylines.first.polylineId.value, 'polyline-1');
      });

      group('Initialization options', () {
        gmaps.MapOptions capturedOptions;
        setUp(() {
          capturedOptions = null;
        });
        testWidgets('translates initial options', (WidgetTester tester) async {
          controller = _createController(options: {
            'options': {
              'mapType': 2,
              'zoomControlsEnabled': true,
            }
          });
          controller.debugSetOverrides(createMap: (_, options) {
            capturedOptions = options;
            return map;
          });

          controller.init();

          expect(capturedOptions, isNotNull);
          expect(capturedOptions.mapTypeId, gmaps.MapTypeId.SATELLITE);
          expect(capturedOptions.zoomControl, true);
          expect(capturedOptions.gestureHandling, 'auto',
              reason:
                  'by default the map handles zoom/pan gestures internally');
        });

        testWidgets('disables gestureHandling with scrollGesturesEnabled false',
            (WidgetTester tester) async {
          controller = _createController(options: {
            'options': {
              'scrollGesturesEnabled': false,
            }
          });
          controller.debugSetOverrides(createMap: (_, options) {
            capturedOptions = options;
            return map;
          });

          controller.init();

          expect(capturedOptions, isNotNull);
          expect(capturedOptions.gestureHandling, 'none',
              reason:
                  'disabling scroll gestures disables all gesture handling');
        });

        testWidgets('disables gestureHandling with zoomGesturesEnabled false',
            (WidgetTester tester) async {
          controller = _createController(options: {
            'options': {
              'zoomGesturesEnabled': false,
            }
          });
          controller.debugSetOverrides(createMap: (_, options) {
            capturedOptions = options;
            return map;
          });

          controller.init();

          expect(capturedOptions, isNotNull);
          expect(capturedOptions.gestureHandling, 'none',
              reason:
                  'disabling scroll gestures disables all gesture handling');
        });

        testWidgets('does not set initial position if absent',
            (WidgetTester tester) async {
          controller = _createController();
          controller.debugSetOverrides(createMap: (_, options) {
            capturedOptions = options;
            return map;
          });

          controller.init();

          expect(capturedOptions, isNotNull);
          expect(capturedOptions.zoom, isNull);
          expect(capturedOptions.center, isNull);
        });

        testWidgets('sets initial position when passed',
            (WidgetTester tester) async {
          controller = _createController(options: {
            'initialCameraPosition': {
              'target': [43.308, -5.6910],
              'zoom': 12,
              'bearing': 0,
              'tilt': 0,
            }
          });
          controller.debugSetOverrides(createMap: (_, options) {
            capturedOptions = options;
            return map;
          });

          controller.init();

          expect(capturedOptions, isNotNull);
          expect(capturedOptions.zoom, 12);
          expect(capturedOptions.center, isNotNull);
        });
      });

      group('Traffic Layer', () {
        testWidgets('by default is disabled', (WidgetTester tester) async {
          controller = _createController();
          controller.init();
          expect(controller.trafficLayer, isNull);
        });

        testWidgets('initializes with traffic layer',
            (WidgetTester tester) async {
          controller = _createController(options: {
            'options': {
              'trafficEnabled': true,
            }
          });
          controller.debugSetOverrides(createMap: (_, __) => map);
          controller.init();
          expect(controller.trafficLayer, isNotNull);
        });
      });
    });

    // These are the methods that are delegated to the gmaps.GMap object, that we can mock...
    group('Map control methods', () {
      _MockGMap map;

      setUp(() {
        map = _MockGMap();
        controller = _createController();
        controller.debugSetOverrides(createMap: (_, __) => map);
        controller.init();
      });

      group('updateRawOptions', () {
        testWidgets('can update `options`', (WidgetTester tester) async {
          controller.updateRawOptions({
            'mapType': 2,
          });
          final options = verify(map.options = captureAny).captured[0];

          expect(options.mapTypeId, gmaps.MapTypeId.SATELLITE);
        });

        testWidgets('can turn on/off traffic', (WidgetTester tester) async {
          expect(controller.trafficLayer, isNull);

          controller.updateRawOptions({
            'trafficEnabled': true,
          });

          expect(controller.trafficLayer, isNotNull);

          controller.updateRawOptions({
            'trafficEnabled': false,
          });

          expect(controller.trafficLayer, isNull);
        });
      });

      group('viewport getters', () {
        testWidgets('getVisibleRegion', (WidgetTester tester) async {
          await controller.getVisibleRegion();

          verify(map.bounds);
        });

        testWidgets('getZoomLevel', (WidgetTester tester) async {
          when(map.zoom).thenReturn(10);

          await controller.getZoomLevel();

          verify(map.zoom);
        });
      });

      group('moveCamera', () {
        testWidgets('newLatLngZoom', (WidgetTester tester) async {
          await (controller
              .moveCamera(CameraUpdate.newLatLngZoom(LatLng(19, 26), 12)));

          verify(map.zoom = 12);
          final captured = verify(map.panTo(captureAny)).captured[0];
          expect(captured.lat, 19);
          expect(captured.lng, 26);
        });
      });

      group('map.projection methods', () {
        // These are too much for dart mockito, can't mock:
        // map.projection.method() (in Javascript ;) )
      });
    });

    // These are the methods that get forwarded to other controllers, so we just verify calls.
    group('Pass-through methods', () {
      setUp(() {
        controller = _createController();
      });

      testWidgets('updateCircles', (WidgetTester tester) async {
        final mock = _MockCirclesController();
        controller.debugSetOverrides(circles: mock);

        final previous = {
          Circle(circleId: CircleId('to-be-updated')),
          Circle(circleId: CircleId('to-be-removed')),
        };

        final current = {
          Circle(circleId: CircleId('to-be-updated'), visible: false),
          Circle(circleId: CircleId('to-be-added')),
        };

        controller.updateCircles(CircleUpdates.from(previous, current));

        verify(mock.removeCircles({
          CircleId('to-be-removed'),
        }));
        verify(mock.addCircles({
          Circle(circleId: CircleId('to-be-added')),
        }));
        verify(mock.changeCircles({
          Circle(circleId: CircleId('to-be-updated'), visible: false),
        }));
      });

      testWidgets('updateMarkers', (WidgetTester tester) async {
        final mock = _MockMarkersController();
        controller.debugSetOverrides(markers: mock);

        final previous = {
          Marker(markerId: MarkerId('to-be-updated')),
          Marker(markerId: MarkerId('to-be-removed')),
        };

        final current = {
          Marker(markerId: MarkerId('to-be-updated'), visible: false),
          Marker(markerId: MarkerId('to-be-added')),
        };

        controller.updateMarkers(MarkerUpdates.from(previous, current));

        verify(mock.removeMarkers({
          MarkerId('to-be-removed'),
        }));
        verify(mock.addMarkers({
          Marker(markerId: MarkerId('to-be-added')),
        }));
        verify(mock.changeMarkers({
          Marker(markerId: MarkerId('to-be-updated'), visible: false),
        }));
      });

      testWidgets('updatePolygons', (WidgetTester tester) async {
        final mock = _MockPolygonsController();
        controller.debugSetOverrides(polygons: mock);

        final previous = {
          Polygon(polygonId: PolygonId('to-be-updated')),
          Polygon(polygonId: PolygonId('to-be-removed')),
        };

        final current = {
          Polygon(polygonId: PolygonId('to-be-updated'), visible: false),
          Polygon(polygonId: PolygonId('to-be-added')),
        };

        controller.updatePolygons(PolygonUpdates.from(previous, current));

        verify(mock.removePolygons({
          PolygonId('to-be-removed'),
        }));
        verify(mock.addPolygons({
          Polygon(polygonId: PolygonId('to-be-added')),
        }));
        verify(mock.changePolygons({
          Polygon(polygonId: PolygonId('to-be-updated'), visible: false),
        }));
      });

      testWidgets('updatePolylines', (WidgetTester tester) async {
        final mock = _MockPolylinesController();
        controller.debugSetOverrides(polylines: mock);

        final previous = {
          Polyline(polylineId: PolylineId('to-be-updated')),
          Polyline(polylineId: PolylineId('to-be-removed')),
        };

        final current = {
          Polyline(polylineId: PolylineId('to-be-updated'), visible: false),
          Polyline(polylineId: PolylineId('to-be-added')),
        };

        controller.updatePolylines(PolylineUpdates.from(previous, current));

        verify(mock.removePolylines({
          PolylineId('to-be-removed'),
        }));
        verify(mock.addPolylines({
          Polyline(polylineId: PolylineId('to-be-added')),
        }));
        verify(mock.changePolylines({
          Polyline(polylineId: PolylineId('to-be-updated'), visible: false),
        }));
      });

      testWidgets('infoWindow visibility', (WidgetTester tester) async {
        final mock = _MockMarkersController();
        controller.debugSetOverrides(markers: mock);
        final markerId = MarkerId('marker-with-infowindow');

        controller.showInfoWindow(markerId);

        verify(mock.showMarkerInfoWindow(markerId));

        controller.hideInfoWindow(markerId);

        verify(mock.hideMarkerInfoWindow(markerId));

        controller.isInfoWindowShown(markerId);

        verify(mock.isInfoWindowShown(markerId));
      });
    });
  });
}
