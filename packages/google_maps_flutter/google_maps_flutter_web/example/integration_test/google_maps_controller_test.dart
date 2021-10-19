// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:html' as html;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps/google_maps.dart' as gmaps;
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'google_maps_controller_test.mocks.dart';

// This value is used when comparing long~num, like
// LatLng values.
const _acceptableDelta = 0.0000000001;

@GenerateMocks([], customMocks: [
  MockSpec<CirclesController>(returnNullOnMissingStub: true),
  MockSpec<PolygonsController>(returnNullOnMissingStub: true),
  MockSpec<PolylinesController>(returnNullOnMissingStub: true),
  MockSpec<MarkersController>(returnNullOnMissingStub: true),
])

/// Test Google Map Controller
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('GoogleMapController', () {
    final int mapId = 33930;
    late GoogleMapController controller;
    late StreamController<MapEvent> stream;

    // Creates a controller with the default mapId and stream controller, and any `options` needed.
    GoogleMapController _createController({
      CameraPosition initialCameraPosition =
          const CameraPosition(target: LatLng(0, 0)),
      Set<Marker> markers = const <Marker>{},
      Set<Polygon> polygons = const <Polygon>{},
      Set<Polyline> polylines = const <Polyline>{},
      Set<Circle> circles = const <Circle>{},
      Map<String, dynamic> options = const <String, dynamic>{},
    }) {
      return GoogleMapController(
        mapId: mapId,
        streamController: stream,
        initialCameraPosition: initialCameraPosition,
        markers: markers,
        polygons: polygons,
        polylines: polylines,
        circles: circles,
        mapOptions: options,
      );
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
        expect(controller.widget, isA<HtmlElementView>());
        expect((controller.widget as HtmlElementView).viewType,
            endsWith('$mapId'));
      });

      testWidgets('widget is cached when reused', (WidgetTester tester) async {
        final first = controller.widget;
        final again = controller.widget;
        expect(identical(first, again), isTrue);
      });

      group('dispose', () {
        testWidgets('closes the stream and removes the widget',
            (WidgetTester tester) async {
          controller.dispose();

          expect(stream.isClosed, isTrue);
          expect(controller.widget, isNull);
        });

        testWidgets('cannot call getVisibleRegion after dispose',
            (WidgetTester tester) async {
          controller.dispose();

          expect(() async {
            await controller.getVisibleRegion();
          }, throwsAssertionError);
        });

        testWidgets('cannot call getScreenCoordinate after dispose',
            (WidgetTester tester) async {
          controller.dispose();

          expect(() async {
            await controller.getScreenCoordinate(
              LatLng(43.3072465, -5.6918241),
            );
          }, throwsAssertionError);
        });

        testWidgets('cannot call getLatLng after dispose',
            (WidgetTester tester) async {
          controller.dispose();

          expect(() async {
            await controller.getLatLng(
              ScreenCoordinate(x: 640, y: 480),
            );
          }, throwsAssertionError);
        });

        testWidgets('cannot call moveCamera after dispose',
            (WidgetTester tester) async {
          controller.dispose();

          expect(() async {
            await controller.moveCamera(CameraUpdate.zoomIn());
          }, throwsAssertionError);
        });

        testWidgets('cannot call getZoomLevel after dispose',
            (WidgetTester tester) async {
          controller.dispose();

          expect(() async {
            await controller.getZoomLevel();
          }, throwsAssertionError);
        });

        testWidgets('cannot updateCircles after dispose',
            (WidgetTester tester) async {
          controller.dispose();

          expect(() {
            controller.updateCircles(CircleUpdates.from({}, {}));
          }, throwsAssertionError);
        });

        testWidgets('cannot updatePolygons after dispose',
            (WidgetTester tester) async {
          controller.dispose();

          expect(() {
            controller.updatePolygons(PolygonUpdates.from({}, {}));
          }, throwsAssertionError);
        });

        testWidgets('cannot updatePolylines after dispose',
            (WidgetTester tester) async {
          controller.dispose();

          expect(() {
            controller.updatePolylines(PolylineUpdates.from({}, {}));
          }, throwsAssertionError);
        });

        testWidgets('cannot updateMarkers after dispose',
            (WidgetTester tester) async {
          controller.dispose();

          expect(() {
            controller.updateMarkers(MarkerUpdates.from({}, {}));
          }, throwsAssertionError);

          expect(() {
            controller.showInfoWindow(MarkerId('any'));
          }, throwsAssertionError);

          expect(() {
            controller.hideInfoWindow(MarkerId('any'));
          }, throwsAssertionError);
        });

        testWidgets('isInfoWindowShown defaults to false',
            (WidgetTester tester) async {
          controller.dispose();

          expect(controller.isInfoWindowShown(MarkerId('any')), false);
        });
      });
    });

    group('init', () {
      late MockCirclesController circles;
      late MockMarkersController markers;
      late MockPolygonsController polygons;
      late MockPolylinesController polylines;
      late gmaps.GMap map;

      setUp(() {
        circles = MockCirclesController();
        markers = MockMarkersController();
        polygons = MockPolygonsController();
        polylines = MockPolylinesController();
        map = gmaps.GMap(html.DivElement());
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

        controller.init();

        // Trigger events on the map, and verify they've been broadcast to the stream
        final capturedEvents = stream.stream.take(5);

        gmaps.Event.trigger(
            map, 'click', [gmaps.MapMouseEvent()..latLng = gmaps.LatLng(0, 0)]);
        gmaps.Event.trigger(map, 'rightclick',
            [gmaps.MapMouseEvent()..latLng = gmaps.LatLng(0, 0)]);
        gmaps.Event.trigger(map, 'bounds_changed', []); // Causes 2 events
        gmaps.Event.trigger(map, 'idle', []);

        final events = await capturedEvents.toList();

        expect(events[0], isA<MapTapEvent>());
        expect(events[1], isA<MapLongPressEvent>());
        expect(events[2], isA<CameraMoveStartedEvent>());
        expect(events[3], isA<CameraMoveEvent>());
        expect(events[4], isA<CameraIdleEvent>());
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
        controller = _createController(circles: {
          Circle(
            circleId: CircleId('circle-1'),
            zIndex: 1234,
          ),
        }, markers: {
          Marker(
            markerId: MarkerId('marker-1'),
            infoWindow: InfoWindow(
              title: 'title for test',
              snippet: 'snippet for test',
            ),
          ),
        }, polygons: {
          Polygon(polygonId: PolygonId('polygon-1'), points: [
            LatLng(43.355114, -5.851333),
            LatLng(43.354797, -5.851860),
            LatLng(43.354469, -5.851318),
            LatLng(43.354762, -5.850824),
          ]),
          Polygon(
            polygonId: PolygonId('polygon-2-with-holes'),
            points: [
              LatLng(43.355114, -5.851333),
              LatLng(43.354797, -5.851860),
              LatLng(43.354469, -5.851318),
              LatLng(43.354762, -5.850824),
            ],
            holes: [
              [
                LatLng(41.354797, -6.851860),
                LatLng(41.354469, -6.851318),
                LatLng(41.354762, -6.850824),
              ]
            ],
          ),
        }, polylines: {
          Polyline(polylineId: PolylineId('polyline-1'), points: [
            LatLng(43.355114, -5.851333),
            LatLng(43.354797, -5.851860),
            LatLng(43.354469, -5.851318),
            LatLng(43.354762, -5.850824),
          ])
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
        expect(capturedCircles.first.zIndex, 1234);
        expect(capturedMarkers.first.markerId.value, 'marker-1');
        expect(capturedMarkers.first.infoWindow.snippet, 'snippet for test');
        expect(capturedMarkers.first.infoWindow.title, 'title for test');
        expect(capturedPolygons.first.polygonId.value, 'polygon-1');
        expect(capturedPolygons.elementAt(1).polygonId.value,
            'polygon-2-with-holes');
        expect(capturedPolygons.elementAt(1).holes, isNot(null));
        expect(capturedPolylines.first.polylineId.value, 'polyline-1');
      });

      testWidgets('empty infoWindow does not create InfoWindow instance.',
          (WidgetTester tester) async {
        controller = _createController(markers: {
          Marker(markerId: MarkerId('marker-1')),
        });

        controller.debugSetOverrides(
          markers: markers,
        );

        controller.init();

        final capturedMarkers =
            verify(markers.addMarkers(captureAny)).captured[0] as Set<Marker>;

        expect(capturedMarkers.first.infoWindow, InfoWindow.noText);
      });

      group('Initialization options', () {
        gmaps.MapOptions? capturedOptions;
        setUp(() {
          capturedOptions = null;
        });
        testWidgets('translates initial options', (WidgetTester tester) async {
          controller = _createController(options: {
            'mapType': 2,
            'zoomControlsEnabled': true,
          });
          controller.debugSetOverrides(createMap: (_, options) {
            capturedOptions = options;
            return map;
          });

          controller.init();

          expect(capturedOptions, isNotNull);
          expect(capturedOptions!.mapTypeId, gmaps.MapTypeId.SATELLITE);
          expect(capturedOptions!.zoomControl, true);
          expect(capturedOptions!.gestureHandling, 'auto',
              reason:
                  'by default the map handles zoom/pan gestures internally');
        });

        testWidgets('disables gestureHandling with scrollGesturesEnabled false',
            (WidgetTester tester) async {
          controller = _createController(options: {
            'scrollGesturesEnabled': false,
          });
          controller.debugSetOverrides(createMap: (_, options) {
            capturedOptions = options;
            return map;
          });

          controller.init();

          expect(capturedOptions, isNotNull);
          expect(capturedOptions!.gestureHandling, 'none',
              reason:
                  'disabling scroll gestures disables all gesture handling');
        });

        testWidgets('disables gestureHandling with zoomGesturesEnabled false',
            (WidgetTester tester) async {
          controller = _createController(options: {
            'zoomGesturesEnabled': false,
          });
          controller.debugSetOverrides(createMap: (_, options) {
            capturedOptions = options;
            return map;
          });

          controller.init();

          expect(capturedOptions, isNotNull);
          expect(capturedOptions!.gestureHandling, 'none',
              reason:
                  'disabling scroll gestures disables all gesture handling');
        });

        testWidgets('sets initial position when passed',
            (WidgetTester tester) async {
          controller = _createController(
            initialCameraPosition: CameraPosition(
              target: LatLng(43.308, -5.6910),
              zoom: 12,
              bearing: 0,
              tilt: 0,
            ),
          );

          controller.debugSetOverrides(createMap: (_, options) {
            capturedOptions = options;
            return map;
          });

          controller.init();

          expect(capturedOptions, isNotNull);
          expect(capturedOptions!.zoom, 12);
          expect(capturedOptions!.center, isNotNull);
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
            'trafficEnabled': true,
          });
          controller.debugSetOverrides(createMap: (_, __) => map);
          controller.init();
          expect(controller.trafficLayer, isNotNull);
        });
      });
    });

    // These are the methods that are delegated to the gmaps.GMap object, that we can mock...
    group('Map control methods', () {
      late gmaps.GMap map;

      setUp(() {
        map = gmaps.GMap(
          html.DivElement(),
          gmaps.MapOptions()
            ..zoom = 10
            ..center = gmaps.LatLng(0, 0),
        );
        controller = _createController();
        controller.debugSetOverrides(createMap: (_, __) => map);
        controller.init();
      });

      group('updateRawOptions', () {
        testWidgets('can update `options`', (WidgetTester tester) async {
          controller.updateRawOptions({
            'mapType': 2,
          });

          expect(map.mapTypeId, gmaps.MapTypeId.SATELLITE);
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
          final gmCenter = map.center!;
          final center =
              LatLng(gmCenter.lat.toDouble(), gmCenter.lng.toDouble());

          final bounds = await controller.getVisibleRegion();

          expect(bounds.contains(center), isTrue,
              reason:
                  'The computed visible region must contain the center of the created map.');
        });

        testWidgets('getZoomLevel', (WidgetTester tester) async {
          expect(await controller.getZoomLevel(), map.zoom);
        });
      });

      group('moveCamera', () {
        testWidgets('newLatLngZoom', (WidgetTester tester) async {
          await (controller
              .moveCamera(CameraUpdate.newLatLngZoom(LatLng(19, 26), 12)));

          final gmCenter = map.center!;

          expect(map.zoom, 12);
          expect(gmCenter.lat, closeTo(19, _acceptableDelta));
          expect(gmCenter.lng, closeTo(26, _acceptableDelta));
        });
      });

      group('map.projection methods', () {
        // These are too much for dart mockito, can't mock:
        // map.projection.method() (in Javascript ;) )

        // Caused https://github.com/flutter/flutter/issues/67606
      });
    });

    // These are the methods that get forwarded to other controllers, so we just verify calls.
    group('Pass-through methods', () {
      setUp(() {
        controller = _createController();
      });

      testWidgets('updateCircles', (WidgetTester tester) async {
        final mock = MockCirclesController();
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
        final mock = MockMarkersController();
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
        final mock = MockPolygonsController();
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
        final mock = MockPolylinesController();
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
        final mock = MockMarkersController();
        final markerId = MarkerId('marker-with-infowindow');
        when(mock.isInfoWindowShown(markerId)).thenReturn(true);
        controller.debugSetOverrides(markers: mock);

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
