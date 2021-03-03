// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart = 2.9

import 'dart:async';

import 'package:integration_test/integration_test.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps/google_maps.dart' as gmaps;
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

class _MockGoogleMapController extends Mock implements GoogleMapController {}

/// Test GoogleMapsPlugin
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('GoogleMapsPlugin', () {
    _MockGoogleMapController controller;
    GoogleMapsPlugin plugin;
    int reportedMapId;

    void onPlatformViewCreated(int id) {
      reportedMapId = id;
    }

    setUp(() {
      controller = _MockGoogleMapController();
      plugin = GoogleMapsPlugin();
      reportedMapId = null;
    });

    group('init/dispose', () {
      group('before buildWidget', () {
        testWidgets('init throws assertion', (WidgetTester tester) async {
          expect(() => plugin.init(0), throwsAssertionError);
        });
      });

      group('after buildWidget', () {
        setUp(() {
          plugin.debugSetMapById({0: controller});
        });

        testWidgets('init initializes controller', (WidgetTester tester) async {
          await plugin.init(0);

          verify(controller.init());
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
      final testMapId = 33930;
      final initialCameraPosition = CameraPosition(target: LatLng(0, 0));

      testWidgets('throws without _webOnlyMapCreationId',
          (WidgetTester tester) async {
        expect(
          () => plugin.buildView(
            null,
            onPlatformViewCreated,
            initialCameraPosition: initialCameraPosition,
          ),
          throwsAssertionError,
          reason:
              '_webOnlyMapCreationId is mandatory to prevent unnecessary reloads in web.',
        );
      });

      testWidgets(
          'returns an HtmlElementView and caches the controller for later',
          (WidgetTester tester) async {
        final Map<int, GoogleMapController> cache = {};
        plugin.debugSetMapById(cache);

        final HtmlElementView widget = plugin.buildView(
          testMapId,
          onPlatformViewCreated,
          initialCameraPosition: initialCameraPosition,
        );

        expect(
          widget.viewType,
          contains('$testMapId'),
          reason:
              'view type should contain the mapId passed when creating the map.',
        );
        expect(
          reportedMapId,
          testMapId,
          reason: 'Should call onPlatformViewCreated with the mapId',
        );
        expect(cache, contains(testMapId));
        expect(
          cache[testMapId],
          isNotNull,
          reason: 'cached controller cannot be null.',
        );
      });

      testWidgets('returns cached instance if it already exists',
          (WidgetTester tester) async {
        final expected = HtmlElementView(viewType: 'only-for-testing');
        when(controller.widget).thenReturn(expected);
        plugin.debugSetMapById({testMapId: controller});

        final widget = plugin.buildView(
          testMapId,
          onPlatformViewCreated,
          initialCameraPosition: initialCameraPosition,
        );

        expect(widget, equals(expected));
        expect(
          reportedMapId,
          isNull,
          reason:
              'onPlatformViewCreated should not be called when returning a cached controller',
        );
      });
    });

    group('setMapStyles', () {
      String mapStyle = '''[{
        "featureType": "poi.park",
        "elementType": "labels.text.fill",
        "stylers": [{"color": "#6b9a76"}]
      }]''';

      testWidgets('translates styles for controller',
          (WidgetTester tester) async {
        plugin.debugSetMapById({0: controller});

        await plugin.setMapStyle(mapStyle, mapId: 0);

        var captured =
            verify(controller.updateRawOptions(captureThat(isMap))).captured[0];

        expect(captured, contains('styles'));
        var styles = captured['styles'];
        expect(styles.length, 1);
        // Let's peek inside the styles...
        var style = styles[0] as gmaps.MapTypeStyle;
        expect(style.featureType, gmaps.MapTypeStyleFeatureType.POI_PARK);
        expect(
            style.elementType, gmaps.MapTypeStyleElementType.LABELS_TEXT_FILL);
        expect(style.stylers.length, 1);
        expect(style.stylers[0].color, '#6b9a76');
      });
    });

    group('Noop methods:', () {
      int mapId = 0;
      setUp(() {
        plugin.debugSetMapById({mapId: controller});
      });
      // Options
      testWidgets('updateTileOverlays', (WidgetTester tester) async {
        final update =
            plugin.updateTileOverlays(mapId: mapId, newTileOverlays: {});
        expect(update, completion(null));
      });
      testWidgets('updateTileOverlays', (WidgetTester tester) async {
        final update =
            plugin.clearTileCache(TileOverlayId('any'), mapId: mapId);
        expect(update, completion(null));
      });
    });

    // These methods only pass-through values from the plugin to the controller
    // so we verify them all together here...
    group('Pass-through methods:', () {
      int mapId = 0;
      setUp(() {
        plugin.debugSetMapById({mapId: controller});
      });
      // Options
      testWidgets('updateMapOptions', (WidgetTester tester) async {
        final expectedMapOptions = <String, dynamic>{'someOption': 12345};

        await plugin.updateMapOptions(expectedMapOptions, mapId: mapId);

        verify(controller.updateRawOptions(expectedMapOptions));
      });
      // Geometry
      testWidgets('updateMarkers', (WidgetTester tester) async {
        final expectedUpdates = MarkerUpdates.from({}, {});

        await plugin.updateMarkers(expectedUpdates, mapId: mapId);

        verify(controller.updateMarkers(expectedUpdates));
      });
      testWidgets('updatePolygons', (WidgetTester tester) async {
        final expectedUpdates = PolygonUpdates.from({}, {});

        await plugin.updatePolygons(expectedUpdates, mapId: mapId);

        verify(controller.updatePolygons(expectedUpdates));
      });
      testWidgets('updatePolylines', (WidgetTester tester) async {
        final expectedUpdates = PolylineUpdates.from({}, {});

        await plugin.updatePolylines(expectedUpdates, mapId: mapId);

        verify(controller.updatePolylines(expectedUpdates));
      });
      testWidgets('updateCircles', (WidgetTester tester) async {
        final expectedUpdates = CircleUpdates.from({}, {});

        await plugin.updateCircles(expectedUpdates, mapId: mapId);

        verify(controller.updateCircles(expectedUpdates));
      });
      // Camera
      testWidgets('animateCamera', (WidgetTester tester) async {
        final expectedUpdates =
            CameraUpdate.newLatLng(LatLng(43.3626, -5.8433));

        await plugin.animateCamera(expectedUpdates, mapId: mapId);

        verify(controller.moveCamera(expectedUpdates));
      });
      testWidgets('moveCamera', (WidgetTester tester) async {
        final expectedUpdates =
            CameraUpdate.newLatLng(LatLng(43.3628, -5.8478));

        await plugin.moveCamera(expectedUpdates, mapId: mapId);

        verify(controller.moveCamera(expectedUpdates));
      });
      // Viewport
      testWidgets('getVisibleRegion', (WidgetTester tester) async {
        await plugin.getVisibleRegion(mapId: mapId);

        verify(controller.getVisibleRegion());
      });
      testWidgets('getZoomLevel', (WidgetTester tester) async {
        await plugin.getZoomLevel(mapId: mapId);

        verify(controller.getZoomLevel());
      });
      testWidgets('getScreenCoordinate', (WidgetTester tester) async {
        final latLng = LatLng(43.3613, -5.8499);

        await plugin.getScreenCoordinate(latLng, mapId: mapId);

        verify(controller.getScreenCoordinate(latLng));
      });
      testWidgets('getLatLng', (WidgetTester tester) async {
        final coordinates = ScreenCoordinate(x: 19, y: 26);

        await plugin.getLatLng(coordinates, mapId: mapId);

        verify(controller.getLatLng(coordinates));
      });
      // InfoWindows
      testWidgets('showMarkerInfoWindow', (WidgetTester tester) async {
        final markerId = MarkerId('testing-123');

        await plugin.showMarkerInfoWindow(markerId, mapId: mapId);

        verify(controller.showInfoWindow(markerId));
      });
      testWidgets('hideMarkerInfoWindow', (WidgetTester tester) async {
        final markerId = MarkerId('testing-123');

        await plugin.hideMarkerInfoWindow(markerId, mapId: mapId);

        verify(controller.hideInfoWindow(markerId));
      });
      testWidgets('isMarkerInfoWindowShown', (WidgetTester tester) async {
        final markerId = MarkerId('testing-123');

        await plugin.isMarkerInfoWindowShown(markerId, mapId: mapId);

        verify(controller.isInfoWindowShown(markerId));
      });
    });

    // Verify all event streams are filtered correctly from the main one...
    group('Event Streams', () {
      int mapId = 0;
      StreamController<MapEvent> streamController;
      setUp(() {
        streamController = StreamController<MapEvent>.broadcast();
        when(controller.events)
            .thenAnswer((realInvocation) => streamController.stream);
        plugin.debugSetMapById({mapId: controller});
      });

      // Dispatches a few events in the global streamController, and expects *only* the passed event to be there.
      void _testStreamFiltering(Stream<MapEvent> stream, MapEvent event) async {
        Timer.run(() {
          streamController.add(_OtherMapEvent(mapId));
          streamController.add(event);
          streamController.add(_OtherMapEvent(mapId));
          streamController.close();
        });

        final events = await stream.toList();

        expect(events.length, 1);
        expect(events[0], event);
      }

      // Camera events
      testWidgets('onCameraMoveStarted', (WidgetTester tester) async {
        final event = CameraMoveStartedEvent(mapId);

        final stream = plugin.onCameraMoveStarted(mapId: mapId);

        await _testStreamFiltering(stream, event);
      });
      testWidgets('onCameraMoveStarted', (WidgetTester tester) async {
        final event = CameraMoveEvent(
          mapId,
          CameraPosition(
            target: LatLng(43.3790, -5.8660),
          ),
        );

        final stream = plugin.onCameraMove(mapId: mapId);

        await _testStreamFiltering(stream, event);
      });
      testWidgets('onCameraIdle', (WidgetTester tester) async {
        final event = CameraIdleEvent(mapId);

        final stream = plugin.onCameraIdle(mapId: mapId);

        await _testStreamFiltering(stream, event);
      });
      // Marker events
      testWidgets('onMarkerTap', (WidgetTester tester) async {
        final event = MarkerTapEvent(mapId, MarkerId('test-123'));

        final stream = plugin.onMarkerTap(mapId: mapId);

        await _testStreamFiltering(stream, event);
      });
      testWidgets('onInfoWindowTap', (WidgetTester tester) async {
        final event = InfoWindowTapEvent(mapId, MarkerId('test-123'));

        final stream = plugin.onInfoWindowTap(mapId: mapId);

        await _testStreamFiltering(stream, event);
      });
      testWidgets('onMarkerDragEnd', (WidgetTester tester) async {
        final event = MarkerDragEndEvent(
          mapId,
          LatLng(43.3677, -5.8372),
          MarkerId('test-123'),
        );

        final stream = plugin.onMarkerDragEnd(mapId: mapId);

        await _testStreamFiltering(stream, event);
      });
      // Geometry
      testWidgets('onPolygonTap', (WidgetTester tester) async {
        final event = PolygonTapEvent(mapId, PolygonId('test-123'));

        final stream = plugin.onPolygonTap(mapId: mapId);

        await _testStreamFiltering(stream, event);
      });
      testWidgets('onPolylineTap', (WidgetTester tester) async {
        final event = PolylineTapEvent(mapId, PolylineId('test-123'));

        final stream = plugin.onPolylineTap(mapId: mapId);

        await _testStreamFiltering(stream, event);
      });
      testWidgets('onCircleTap', (WidgetTester tester) async {
        final event = CircleTapEvent(mapId, CircleId('test-123'));

        final stream = plugin.onCircleTap(mapId: mapId);

        await _testStreamFiltering(stream, event);
      });
      // Map taps
      testWidgets('onTap', (WidgetTester tester) async {
        final event = MapTapEvent(mapId, LatLng(43.3597, -5.8458));

        final stream = plugin.onTap(mapId: mapId);

        await _testStreamFiltering(stream, event);
      });
      testWidgets('onLongPress', (WidgetTester tester) async {
        final event = MapLongPressEvent(mapId, LatLng(43.3608, -5.8425));

        final stream = plugin.onLongPress(mapId: mapId);

        await _testStreamFiltering(stream, event);
      });
    });
  });
}

class _OtherMapEvent extends MapEvent<void> {
  _OtherMapEvent(int mapId) : super(mapId, null);
}
