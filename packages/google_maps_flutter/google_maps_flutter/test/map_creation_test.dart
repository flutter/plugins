// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:mockito/mockito.dart';

class MockGoogleMapsFlutterPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements GoogleMapsFlutterPlatform {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final platform = MockGoogleMapsFlutterPlatform();

  setUp(() {
    // Use a mock platform so we never need to hit the MethodChannel code.
    GoogleMapsFlutterPlatform.instance = platform;
    resetMockitoState();
    _setupMock(platform);
  });

  testWidgets('_webOnlyMapCreationId increments with each GoogleMap widget', (
    WidgetTester tester,
  ) async {
    // Inject two map widgets...
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: const [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(43.362, -5.849),
              ),
            ),
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(47.649, -122.350),
              ),
            ),
          ],
        ),
      ),
    );

    // Verify that each one was created with a different _webOnlyMapCreationId.
    verifyInOrder([
      platform.buildView(
        argThat(containsPair('_webOnlyMapCreationId', 0)),
        any,
        any,
      ),
      platform.buildView(
        argThat(containsPair('_webOnlyMapCreationId', 1)),
        any,
        any,
      ),
    ]);
  });

  testWidgets('Calls platform.dispose when GoogleMap is disposed of', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(43.3608, -5.8702),
      ),
    ));

    // Now dispose of the map...
    await tester.pumpWidget(Container());

    verify(platform.dispose(mapId: anyNamed('mapId')));
  });
}

// Some test setup classes below...

class _MockStream<T> extends Mock implements Stream<T> {}

typedef _CreationCallback = void Function(int);

// Installs test mocks on the platform
void _setupMock(MockGoogleMapsFlutterPlatform platform) {
  // Used to create the view of the map...
  when(platform.buildView(any, any, any)).thenAnswer((realInvocation) {
    // Call the onPlatformViewCreated callback so the controller gets created.
    _CreationCallback onPlatformViewCreatedCb =
        realInvocation.positionalArguments[2];
    onPlatformViewCreatedCb.call(0);
    return Container();
  });
  // Used to create the Controller
  when(platform.onCameraIdle(mapId: anyNamed('mapId')))
      .thenAnswer((_) => _MockStream<CameraIdleEvent>());
  when(platform.onCameraMove(mapId: anyNamed('mapId')))
      .thenAnswer((_) => _MockStream<CameraMoveEvent>());
  when(platform.onCameraMoveStarted(mapId: anyNamed('mapId')))
      .thenAnswer((_) => _MockStream<CameraMoveStartedEvent>());
  when(platform.onCircleTap(mapId: anyNamed('mapId')))
      .thenAnswer((_) => _MockStream<CircleTapEvent>());
  when(platform.onInfoWindowTap(mapId: anyNamed('mapId')))
      .thenAnswer((_) => _MockStream<InfoWindowTapEvent>());
  when(platform.onLongPress(mapId: anyNamed('mapId')))
      .thenAnswer((_) => _MockStream<MapLongPressEvent>());
  when(platform.onMarkerDragEnd(mapId: anyNamed('mapId')))
      .thenAnswer((_) => _MockStream<MarkerDragEndEvent>());
  when(platform.onMarkerTap(mapId: anyNamed('mapId')))
      .thenAnswer((_) => _MockStream<MarkerTapEvent>());
  when(platform.onPolygonTap(mapId: anyNamed('mapId')))
      .thenAnswer((_) => _MockStream<PolygonTapEvent>());
  when(platform.onPolylineTap(mapId: anyNamed('mapId')))
      .thenAnswer((_) => _MockStream<PolylineTapEvent>());
  when(platform.onTap(mapId: anyNamed('mapId')))
      .thenAnswer((_) => _MockStream<MapTapEvent>());
}
