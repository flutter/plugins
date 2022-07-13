// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:js_util' show getProperty;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps/google_maps.dart' as gmaps;
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'google_maps_plugin_test.mocks.dart';

@GenerateMocks(<Type>[], customMocks: <MockSpec<dynamic>>[
  MockSpec<GoogleMapController>(returnNullOnMissingStub: true),
])

/// Test GoogleMapsPlugin
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('GoogleMapsPlugin', () {
    late MockGoogleMapController controller;
    late GoogleMapsPlugin plugin;
    late Completer<int> reportedMapIdCompleter;
    int numberOnPlatformViewCreatedCalls = 0;

    void onPlatformViewCreated(int id) {
      reportedMapIdCompleter.complete(id);
      numberOnPlatformViewCreatedCalls++;
    }

    setUp(() {
      controller = MockGoogleMapController();
      plugin = GoogleMapsPlugin();
      reportedMapIdCompleter = Completer<int>();
    });

    group('init/dispose', () {
      group('before buildWidget', () {
        testWidgets('init throws assertion', (WidgetTester tester) async {
          expect(() => plugin.init(0), throwsAssertionError);
        });
      });

      group('after buildWidget', () {
        setUp(() {
          plugin.debugSetMapById(<int, GoogleMapController>{0: controller});
        });

        testWidgets('cannot call methods after dispose',
            (WidgetTester tester) async {
          plugin.dispose(mapId: 0);

          verify(controller.dispose());
          expect(
            () => plugin.init(0),
            throwsAssertionError,
            reason: 'Method calls should fail after dispose.',
          );
        });
      });
    });

    group('buildView', () {
      const int testMapId = 33930;
      const CameraPosition initialCameraPosition =
          CameraPosition(target: LatLng(0, 0));

      testWidgets(
          'returns an HtmlElementView and caches the controller for later',
          (WidgetTester tester) async {
        final Map<int, GoogleMapController> cache =
            <int, GoogleMapController>{};
        plugin.debugSetMapById(cache);

        final Widget widget = plugin.buildViewWithConfiguration(
          testMapId,
          onPlatformViewCreated,
          widgetConfiguration: const MapWidgetConfiguration(
            initialCameraPosition: initialCameraPosition,
            textDirection: TextDirection.ltr,
          ),
        );

        expect(widget, isA<HtmlElementView>());
        expect(
          (widget as HtmlElementView).viewType,
          contains('$testMapId'),
          reason:
              'view type should contain the mapId passed when creating the map.',
        );
        expect(cache, contains(testMapId));
        expect(
          cache[testMapId],
          isNotNull,
          reason: 'cached controller cannot be null.',
        );
        expect(
          cache[testMapId]!.isInitialized,
          isTrue,
          reason: 'buildView calls init on the controller',
        );
      });

      testWidgets('returns cached instance if it already exists',
          (WidgetTester tester) async {
        const HtmlElementView expected =
            HtmlElementView(viewType: 'only-for-testing');
        when(controller.widget).thenReturn(expected);
        plugin.debugSetMapById(<int, GoogleMapController>{
          testMapId: controller,
        });

        final Widget widget = plugin.buildViewWithConfiguration(
          testMapId,
          onPlatformViewCreated,
          widgetConfiguration: const MapWidgetConfiguration(
            initialCameraPosition: initialCameraPosition,
            textDirection: TextDirection.ltr,
          ),
        );

        expect(widget, equals(expected));
      });

      testWidgets(
          'asynchronously reports onPlatformViewCreated the first time it happens',
          (WidgetTester tester) async {
        final Map<int, GoogleMapController> cache =
            <int, GoogleMapController>{};
        plugin.debugSetMapById(cache);

        plugin.buildViewWithConfiguration(
          testMapId,
          onPlatformViewCreated,
          widgetConfiguration: const MapWidgetConfiguration(
            initialCameraPosition: initialCameraPosition,
            textDirection: TextDirection.ltr,
          ),
        );

        // Simulate Google Maps JS SDK being "ready"
        cache[testMapId]!.stream.add(WebMapReadyEvent(testMapId));

        expect(
          cache[testMapId]!.isInitialized,
          isTrue,
          reason: 'buildView calls init on the controller',
        );
        expect(
          await reportedMapIdCompleter.future,
          testMapId,
          reason: 'Should call onPlatformViewCreated with the mapId',
        );

        // Fire repeated event again...
        cache[testMapId]!.stream.add(WebMapReadyEvent(testMapId));
        expect(
          numberOnPlatformViewCreatedCalls,
          equals(1),
          reason:
              'Should not call onPlatformViewCreated for the same controller multiple times',
        );
      });
    });

    group('setMapStyles', () {
      const String mapStyle = '''
[{
  "featureType": "poi.park",
  "elementType": "labels.text.fill",
  "stylers": [{"color": "#6b9a76"}]
}]''';

      testWidgets('translates styles for controller',
          (WidgetTester tester) async {
        plugin.debugSetMapById(<int, GoogleMapController>{0: controller});

        await plugin.setMapStyle(mapStyle, mapId: 0);

        final dynamic captured =
            verify(controller.updateStyles(captureThat(isList))).captured[0];

        final List<gmaps.MapTypeStyle> styles =
            captured as List<gmaps.MapTypeStyle>;
        expect(styles.length, 1);
        // Let's peek inside the styles...
        final gmaps.MapTypeStyle style = styles[0];
        expect(style.featureType, 'poi.park');
        expect(style.elementType, 'labels.text.fill');
        expect(style.stylers?.length, 1);
        expect(getProperty<String>(style.stylers![0]!, 'color'), '#6b9a76');
      });
    });

    group('Noop methods:', () {
      const int mapId = 0;
      setUp(() {
        plugin.debugSetMapById(<int, GoogleMapController>{mapId: controller});
      });
      // Options
      testWidgets('updateTileOverlays', (WidgetTester tester) async {
        final Future<void> update = plugin.updateTileOverlays(
          mapId: mapId,
          newTileOverlays: <TileOverlay>{},
        );
        expect(update, completion(null));
      });
      testWidgets('updateTileOverlays', (WidgetTester tester) async {
        final Future<void> update = plugin.clearTileCache(
          const TileOverlayId('any'),
          mapId: mapId,
        );
        expect(update, completion(null));
      });
    });

    // These methods only pass-through values from the plugin to the controller
    // so we verify them all together here...
    group('Pass-through methods:', () {
      const int mapId = 0;
      setUp(() {
        plugin.debugSetMapById(<int, GoogleMapController>{mapId: controller});
      });
      // Options
      testWidgets('updateMapConfiguration', (WidgetTester tester) async {
        const MapConfiguration configuration =
            MapConfiguration(mapType: MapType.satellite);

        await plugin.updateMapConfiguration(configuration, mapId: mapId);

        verify(controller.updateMapConfiguration(configuration));
      });
      // Geometry
      testWidgets('updateMarkers', (WidgetTester tester) async {
        final MarkerUpdates expectedUpdates = MarkerUpdates.from(
          const <Marker>{},
          const <Marker>{},
        );

        await plugin.updateMarkers(expectedUpdates, mapId: mapId);

        verify(controller.updateMarkers(expectedUpdates));
      });
      testWidgets('updatePolygons', (WidgetTester tester) async {
        final PolygonUpdates expectedUpdates = PolygonUpdates.from(
          const <Polygon>{},
          const <Polygon>{},
        );

        await plugin.updatePolygons(expectedUpdates, mapId: mapId);

        verify(controller.updatePolygons(expectedUpdates));
      });
      testWidgets('updatePolylines', (WidgetTester tester) async {
        final PolylineUpdates expectedUpdates = PolylineUpdates.from(
          const <Polyline>{},
          const <Polyline>{},
        );

        await plugin.updatePolylines(expectedUpdates, mapId: mapId);

        verify(controller.updatePolylines(expectedUpdates));
      });
      testWidgets('updateCircles', (WidgetTester tester) async {
        final CircleUpdates expectedUpdates = CircleUpdates.from(
          const <Circle>{},
          const <Circle>{},
        );

        await plugin.updateCircles(expectedUpdates, mapId: mapId);

        verify(controller.updateCircles(expectedUpdates));
      });
      // Camera
      testWidgets('animateCamera', (WidgetTester tester) async {
        final CameraUpdate expectedUpdates = CameraUpdate.newLatLng(
          const LatLng(43.3626, -5.8433),
        );

        await plugin.animateCamera(expectedUpdates, mapId: mapId);

        verify(controller.moveCamera(expectedUpdates));
      });
      testWidgets('moveCamera', (WidgetTester tester) async {
        final CameraUpdate expectedUpdates = CameraUpdate.newLatLng(
          const LatLng(43.3628, -5.8478),
        );

        await plugin.moveCamera(expectedUpdates, mapId: mapId);

        verify(controller.moveCamera(expectedUpdates));
      });

      // Viewport
      testWidgets('getVisibleRegion', (WidgetTester tester) async {
        when(controller.getVisibleRegion())
            .thenAnswer((_) async => LatLngBounds(
                  northeast: const LatLng(47.2359634, -68.0192019),
                  southwest: const LatLng(34.5019594, -120.4974629),
                ));
        await plugin.getVisibleRegion(mapId: mapId);

        verify(controller.getVisibleRegion());
      });

      testWidgets('getZoomLevel', (WidgetTester tester) async {
        when(controller.getZoomLevel()).thenAnswer((_) async => 10);
        await plugin.getZoomLevel(mapId: mapId);

        verify(controller.getZoomLevel());
      });

      testWidgets('getScreenCoordinate', (WidgetTester tester) async {
        when(controller.getScreenCoordinate(any)).thenAnswer(
            (_) async => const ScreenCoordinate(x: 320, y: 240) // fake return
            );

        const LatLng latLng = LatLng(43.3613, -5.8499);

        await plugin.getScreenCoordinate(latLng, mapId: mapId);

        verify(controller.getScreenCoordinate(latLng));
      });

      testWidgets('getLatLng', (WidgetTester tester) async {
        when(controller.getLatLng(any)).thenAnswer(
            (_) async => const LatLng(43.3613, -5.8499) // fake return
            );

        const ScreenCoordinate coordinates = ScreenCoordinate(x: 19, y: 26);

        await plugin.getLatLng(coordinates, mapId: mapId);

        verify(controller.getLatLng(coordinates));
      });

      // InfoWindows
      testWidgets('showMarkerInfoWindow', (WidgetTester tester) async {
        const MarkerId markerId = MarkerId('testing-123');

        await plugin.showMarkerInfoWindow(markerId, mapId: mapId);

        verify(controller.showInfoWindow(markerId));
      });

      testWidgets('hideMarkerInfoWindow', (WidgetTester tester) async {
        const MarkerId markerId = MarkerId('testing-123');

        await plugin.hideMarkerInfoWindow(markerId, mapId: mapId);

        verify(controller.hideInfoWindow(markerId));
      });

      testWidgets('isMarkerInfoWindowShown', (WidgetTester tester) async {
        when(controller.isInfoWindowShown(any)).thenReturn(true);

        const MarkerId markerId = MarkerId('testing-123');

        await plugin.isMarkerInfoWindowShown(markerId, mapId: mapId);

        verify(controller.isInfoWindowShown(markerId));
      });
    });

    // Verify all event streams are filtered correctly from the main one...
    group('Event Streams', () {
      const int mapId = 0;
      late StreamController<MapEvent<Object?>> streamController;
      setUp(() {
        streamController = StreamController<MapEvent<Object?>>.broadcast();
        when(controller.events)
            .thenAnswer((Invocation realInvocation) => streamController.stream);
        plugin.debugSetMapById(<int, GoogleMapController>{mapId: controller});
      });

      // Dispatches a few events in the global streamController, and expects *only* the passed event to be there.
      Future<void> _testStreamFiltering(
          Stream<MapEvent<Object?>> stream, MapEvent<Object?> event) async {
        Timer.run(() {
          streamController.add(_OtherMapEvent(mapId));
          streamController.add(event);
          streamController.add(_OtherMapEvent(mapId));
          streamController.close();
        });

        final List<MapEvent<Object?>> events = await stream.toList();

        expect(events.length, 1);
        expect(events[0], event);
      }

      // Camera events
      testWidgets('onCameraMoveStarted', (WidgetTester tester) async {
        final CameraMoveStartedEvent event = CameraMoveStartedEvent(mapId);

        final Stream<CameraMoveStartedEvent> stream =
            plugin.onCameraMoveStarted(mapId: mapId);

        await _testStreamFiltering(stream, event);
      });
      testWidgets('onCameraMoveStarted', (WidgetTester tester) async {
        final CameraMoveEvent event = CameraMoveEvent(
          mapId,
          const CameraPosition(
            target: LatLng(43.3790, -5.8660),
          ),
        );

        final Stream<CameraMoveEvent> stream =
            plugin.onCameraMove(mapId: mapId);

        await _testStreamFiltering(stream, event);
      });
      testWidgets('onCameraIdle', (WidgetTester tester) async {
        final CameraIdleEvent event = CameraIdleEvent(mapId);

        final Stream<CameraIdleEvent> stream =
            plugin.onCameraIdle(mapId: mapId);

        await _testStreamFiltering(stream, event);
      });
      // Marker events
      testWidgets('onMarkerTap', (WidgetTester tester) async {
        final MarkerTapEvent event = MarkerTapEvent(
          mapId,
          const MarkerId('test-123'),
        );

        final Stream<MarkerTapEvent> stream = plugin.onMarkerTap(mapId: mapId);

        await _testStreamFiltering(stream, event);
      });
      testWidgets('onInfoWindowTap', (WidgetTester tester) async {
        final InfoWindowTapEvent event = InfoWindowTapEvent(
          mapId,
          const MarkerId('test-123'),
        );

        final Stream<InfoWindowTapEvent> stream =
            plugin.onInfoWindowTap(mapId: mapId);

        await _testStreamFiltering(stream, event);
      });
      testWidgets('onMarkerDragStart', (WidgetTester tester) async {
        final MarkerDragStartEvent event = MarkerDragStartEvent(
          mapId,
          const LatLng(43.3677, -5.8372),
          const MarkerId('test-123'),
        );

        final Stream<MarkerDragStartEvent> stream =
            plugin.onMarkerDragStart(mapId: mapId);

        await _testStreamFiltering(stream, event);
      });
      testWidgets('onMarkerDrag', (WidgetTester tester) async {
        final MarkerDragEvent event = MarkerDragEvent(
          mapId,
          const LatLng(43.3677, -5.8372),
          const MarkerId('test-123'),
        );

        final Stream<MarkerDragEvent> stream =
            plugin.onMarkerDrag(mapId: mapId);

        await _testStreamFiltering(stream, event);
      });
      testWidgets('onMarkerDragEnd', (WidgetTester tester) async {
        final MarkerDragEndEvent event = MarkerDragEndEvent(
          mapId,
          const LatLng(43.3677, -5.8372),
          const MarkerId('test-123'),
        );

        final Stream<MarkerDragEndEvent> stream =
            plugin.onMarkerDragEnd(mapId: mapId);

        await _testStreamFiltering(stream, event);
      });
      // Geometry
      testWidgets('onPolygonTap', (WidgetTester tester) async {
        final PolygonTapEvent event = PolygonTapEvent(
          mapId,
          const PolygonId('test-123'),
        );

        final Stream<PolygonTapEvent> stream =
            plugin.onPolygonTap(mapId: mapId);

        await _testStreamFiltering(stream, event);
      });
      testWidgets('onPolylineTap', (WidgetTester tester) async {
        final PolylineTapEvent event = PolylineTapEvent(
          mapId,
          const PolylineId('test-123'),
        );

        final Stream<PolylineTapEvent> stream =
            plugin.onPolylineTap(mapId: mapId);

        await _testStreamFiltering(stream, event);
      });
      testWidgets('onCircleTap', (WidgetTester tester) async {
        final CircleTapEvent event = CircleTapEvent(
          mapId,
          const CircleId('test-123'),
        );

        final Stream<CircleTapEvent> stream = plugin.onCircleTap(mapId: mapId);

        await _testStreamFiltering(stream, event);
      });
      // Map taps
      testWidgets('onTap', (WidgetTester tester) async {
        final MapTapEvent event = MapTapEvent(
          mapId,
          const LatLng(43.3597, -5.8458),
        );

        final Stream<MapTapEvent> stream = plugin.onTap(mapId: mapId);

        await _testStreamFiltering(stream, event);
      });
      testWidgets('onLongPress', (WidgetTester tester) async {
        final MapLongPressEvent event = MapLongPressEvent(
          mapId,
          const LatLng(43.3608, -5.8425),
        );

        final Stream<MapLongPressEvent> stream =
            plugin.onLongPress(mapId: mapId);

        await _testStreamFiltering(stream, event);
      });
    });
  });
}

class _OtherMapEvent extends MapEvent<Object?> {
  _OtherMapEvent(int mapId) : super(mapId, null);
}
