// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:async/async.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_ios/google_maps_flutter_ios.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<String> log;

  setUp(() async {
    log = <String>[];
  });

  /// Initializes a map with the given ID and canned responses, logging all
  /// calls to [log].
  void configureMockMap(
    GoogleMapsFlutterIOS maps, {
    required int mapId,
    required Future<dynamic>? Function(MethodCall call) handler,
  }) {
    final MethodChannel channel = maps.ensureChannelInitialized(mapId);
    _ambiguate(TestDefaultBinaryMessengerBinding.instance)!
        .defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) {
        log.add(methodCall.method);
        return handler(methodCall);
      },
    );
  }

  Future<void> sendPlatformMessage(
      int mapId, String method, Map<dynamic, dynamic> data) async {
    final ByteData byteData =
        const StandardMethodCodec().encodeMethodCall(MethodCall(method, data));
    await _ambiguate(TestDefaultBinaryMessengerBinding.instance)!
        .defaultBinaryMessenger
        .handlePlatformMessage('plugins.flutter.dev/google_maps_ios_$mapId',
            byteData, (ByteData? data) {});
  }

  test('registers instance', () async {
    GoogleMapsFlutterIOS.registerWith();
    expect(GoogleMapsFlutterPlatform.instance, isA<GoogleMapsFlutterIOS>());
  });

  // Calls each method that uses invokeMethod with a return type other than
  // void to ensure that the casting/nullability handling succeeds.
  //
  // TODO(stuartmorgan): Remove this once there is real test coverage of
  // each method, since that would cover this issue.
  test('non-void invokeMethods handle types correctly', () async {
    const int mapId = 0;
    final GoogleMapsFlutterIOS maps = GoogleMapsFlutterIOS();
    configureMockMap(maps, mapId: mapId,
        handler: (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'map#getLatLng':
          return <dynamic>[1.0, 2.0];
        case 'markers#isInfoWindowShown':
          return true;
        case 'map#getZoomLevel':
          return 2.5;
        case 'map#takeSnapshot':
          return null;
      }
    });

    await maps.getLatLng(const ScreenCoordinate(x: 0, y: 0), mapId: mapId);
    await maps.isMarkerInfoWindowShown(const MarkerId(''), mapId: mapId);
    await maps.getZoomLevel(mapId: mapId);
    await maps.takeSnapshot(mapId: mapId);
    // Check that all the invokeMethod calls happened.
    expect(log, <String>[
      'map#getLatLng',
      'markers#isInfoWindowShown',
      'map#getZoomLevel',
      'map#takeSnapshot',
    ]);
  });

  test('markers send drag event to correct streams', () async {
    const int mapId = 1;
    final Map<dynamic, dynamic> jsonMarkerDragStartEvent = <dynamic, dynamic>{
      'mapId': mapId,
      'markerId': 'drag-start-marker',
      'position': <double>[1.0, 1.0]
    };
    final Map<dynamic, dynamic> jsonMarkerDragEvent = <dynamic, dynamic>{
      'mapId': mapId,
      'markerId': 'drag-marker',
      'position': <double>[1.0, 1.0]
    };
    final Map<dynamic, dynamic> jsonMarkerDragEndEvent = <dynamic, dynamic>{
      'mapId': mapId,
      'markerId': 'drag-end-marker',
      'position': <double>[1.0, 1.0]
    };

    final GoogleMapsFlutterIOS maps = GoogleMapsFlutterIOS();
    maps.ensureChannelInitialized(mapId);

    final StreamQueue<MarkerDragStartEvent> markerDragStartStream =
        StreamQueue<MarkerDragStartEvent>(maps.onMarkerDragStart(mapId: mapId));
    final StreamQueue<MarkerDragEvent> markerDragStream =
        StreamQueue<MarkerDragEvent>(maps.onMarkerDrag(mapId: mapId));
    final StreamQueue<MarkerDragEndEvent> markerDragEndStream =
        StreamQueue<MarkerDragEndEvent>(maps.onMarkerDragEnd(mapId: mapId));

    await sendPlatformMessage(
        mapId, 'marker#onDragStart', jsonMarkerDragStartEvent);
    await sendPlatformMessage(mapId, 'marker#onDrag', jsonMarkerDragEvent);
    await sendPlatformMessage(
        mapId, 'marker#onDragEnd', jsonMarkerDragEndEvent);

    expect((await markerDragStartStream.next).value.value,
        equals('drag-start-marker'));
    expect((await markerDragStream.next).value.value, equals('drag-marker'));
    expect((await markerDragEndStream.next).value.value,
        equals('drag-end-marker'));
  });
}

/// This allows a value of type T or T? to be treated as a value of type T?.
///
/// We use this so that APIs that have become non-nullable can still be used
/// with `!` and `?` on the stable branch.
T? _ambiguate<T>(T? value) => value;
