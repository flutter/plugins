// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:google_maps_flutter_platform_interface/src/events/map_event.dart';
import 'package:google_maps_flutter_platform_interface/src/method_channel/method_channel_google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'dart:async';

import 'package:async/async.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$MethodChannelGoogleMapsFlutter', () {
    late List<String> log;

    setUp(() async {
      log = <String>[];
    });

    /// Initializes a map with the given ID and canned responses, logging all
    /// calls to [log].
    void configureMockMap(
      MethodChannelGoogleMapsFlutter maps, {
      required int mapId,
      required Future<dynamic>? Function(MethodCall call) handler,
    }) {
      maps
          .ensureChannelInitialized(mapId)
          .setMockMethodCallHandler((MethodCall methodCall) {
        log.add(methodCall.method);
        return handler(methodCall);
      });
    }

    Future<void> sendPlatformMessage(
        int mapId, String method, Map<dynamic, dynamic> data) async {
      final ByteData byteData = const StandardMethodCodec()
          .encodeMethodCall(MethodCall(method, data));
      await TestDefaultBinaryMessengerBinding.instance!.defaultBinaryMessenger
          .handlePlatformMessage(
              "plugins.flutter.io/google_maps_$mapId", byteData, (data) {});
    }

    // Calls each method that uses invokeMethod with a return type other than
    // void to ensure that the casting/nullability handling succeeds.
    //
    // TODO(stuartmorgan): Remove this once there is real test coverage of
    // each method, since that would cover this issue.
    test('non-void invokeMethods handle types correctly', () async {
      const int mapId = 0;
      final MethodChannelGoogleMapsFlutter maps =
          MethodChannelGoogleMapsFlutter();
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

      await maps.getLatLng(ScreenCoordinate(x: 0, y: 0), mapId: mapId);
      await maps.isMarkerInfoWindowShown(MarkerId(''), mapId: mapId);
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
      final jsonMarkerDragStartEvent = <dynamic, dynamic>{
        "mapId": mapId,
        "markerId": "drag-start-marker",
        "position": <double>[1.0, 1.0]
      };
      final jsonMarkerDragEvent = <dynamic, dynamic>{
        "mapId": mapId,
        "markerId": "drag-marker",
        "position": <double>[1.0, 1.0]
      };
      final jsonMarkerDragEndEvent = <dynamic, dynamic>{
        "mapId": mapId,
        "markerId": "drag-end-marker",
        "position": <double>[1.0, 1.0]
      };

      final MethodChannelGoogleMapsFlutter maps =
          MethodChannelGoogleMapsFlutter();
      maps.ensureChannelInitialized(mapId);

      final StreamQueue<MarkerDragStartEvent> markerDragStartStream =
          StreamQueue(maps.onMarkerDragStart(mapId: mapId));
      final StreamQueue<MarkerDragEvent> markerDragStream =
          StreamQueue(maps.onMarkerDrag(mapId: mapId));
      final StreamQueue<MarkerDragEndEvent> markerDragEndStream =
          StreamQueue(maps.onMarkerDragEnd(mapId: mapId));

      await sendPlatformMessage(
          mapId, "marker#onDragStart", jsonMarkerDragStartEvent);
      await sendPlatformMessage(mapId, "marker#onDrag", jsonMarkerDragEvent);
      await sendPlatformMessage(
          mapId, "marker#onDragEnd", jsonMarkerDragEndEvent);

      expect((await markerDragStartStream.next).value.value,
          equals("drag-start-marker"));
      expect((await markerDragStream.next).value.value, equals("drag-marker"));
      expect((await markerDragEndStream.next).value.value,
          equals("drag-end-marker"));
    });
    test('heatmap updates are passed to the correct channel', () async {
      const int mapId = 1;

      final MethodChannelGoogleMapsFlutter maps =
          MethodChannelGoogleMapsFlutter();
      configureMockMap(maps, mapId: mapId,
          handler: (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'heatmaps#update':
            return null;
        }
      });

      final previousHeatmaps = Set<Heatmap>();
      final currentHeatmaps = Set<Heatmap>.from([
        Heatmap(
          heatmapId: HeatmapId("test1"),
          gradient: HeatmapGradient(
              colors: [Color(0xFF2e6e8e), Color(0xFF21908c)],
              startPoints: [0.25, 0.75]),
          points: [WeightedLatLng(LatLng(1, 1), intensity: 20)],
        )
      ]);
      HeatmapUpdates heatmapUpdates =
          HeatmapUpdates.from(previousHeatmaps, currentHeatmaps);

      await maps.updateHeatmaps(heatmapUpdates, mapId: mapId);
      expect(log, <String>[
        'heatmaps#update',
      ]);
    });
  });
}
