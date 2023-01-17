// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps/google_maps.dart' as gmaps;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart'
    hide GoogleMapController;
import 'package:integration_test/integration_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks(<MockSpec<dynamic>>[MockSpec<TileProvider>()])
import 'overlays_test.mocks.dart';

MockTileProvider neverTileProvider() {
  final MockTileProvider tileProvider = MockTileProvider();
  when(tileProvider.getTile(any, any, any))
      .thenAnswer((_) => Completer<Tile>().future);
  return tileProvider;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('TileOverlaysController', () {
    late TileOverlaysController controller;
    late gmaps.GMap map;
    late List<MockTileProvider> tileProviders;
    late List<TileOverlay> tileOverlays;

    /// Queries the current overlay map types for tiles at x = 0, y = 0, zoom =
    /// 0.
    void probeTiles() {
      for (final gmaps.MapType? mapType in map.overlayMapTypes!.array!) {
        mapType?.getTile!(gmaps.Point(0, 0), 0, html.document);
      }
    }

    setUp(() {
      controller = TileOverlaysController();
      map = gmaps.GMap(html.DivElement());
      controller.googleMap = map;

      tileProviders = <MockTileProvider>[
        for (int i = 0; i < 3; ++i) neverTileProvider()
      ];

      tileOverlays = <TileOverlay>[
        for (int i = 0; i < 3; ++i)
          TileOverlay(
              tileOverlayId: TileOverlayId('$i'),
              tileProvider: tileProviders[i],
              zIndex: i)
      ];
    });

    testWidgets('addTileOverlays', (WidgetTester tester) async {
      controller.addTileOverlays(<TileOverlay>{...tileOverlays});
      probeTiles();
      verifyInOrder(<dynamic>[
        tileProviders[0].getTile(any, any, any),
        tileProviders[1].getTile(any, any, any),
        tileProviders[2].getTile(any, any, any),
      ]);
    });

    testWidgets('changeTileOverlays', (WidgetTester tester) async {
      controller.addTileOverlays(<TileOverlay>{...tileOverlays});

      // Set overlay 0 visiblity to false; flip z ordering of 1 and 2, leaving 1
      // unchanged.
      controller.changeTileOverlays(<TileOverlay>{
        tileOverlays[0].copyWith(visibleParam: false),
        tileOverlays[2].copyWith(zIndexParam: 0),
      });

      probeTiles();

      verifyInOrder(<dynamic>[
        tileProviders[2].getTile(any, any, any),
        tileProviders[1].getTile(any, any, any),
      ]);
      verifyZeroInteractions(tileProviders[0]);

      // Re-enable overlay 0.
      controller.changeTileOverlays(
          <TileOverlay>{tileOverlays[0].copyWith(visibleParam: true)});

      probeTiles();

      verify(tileProviders[2].getTile(any, any, any));
      verifyInOrder(<dynamic>[
        tileProviders[0].getTile(any, any, any),
        tileProviders[1].getTile(any, any, any),
      ]);
    });

    testWidgets('removeTileOverlaysMarkers', (WidgetTester tester) async {
      controller.addTileOverlays(<TileOverlay>{...tileOverlays});

      controller.removeTileOverlays(<TileOverlayId>{
        tileOverlays[0].tileOverlayId,
        tileOverlays[2].tileOverlayId,
      });

      probeTiles();

      verify(tileProviders[1].getTile(any, any, any));
      verifyZeroInteractions(tileProviders[0]);
      verifyZeroInteractions(tileProviders[2]);
    });

    testWidgets('clearTileCache', (WidgetTester tester) async {
      final Completer<GoogleMapController> controllerCompleter =
          Completer<GoogleMapController>();
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(43.3078, -5.6958),
          zoom: 14,
        ),
        tileOverlays: <TileOverlay>{...tileOverlays.take(2)},
        onMapCreated: (GoogleMapController value) {
          controllerCompleter.complete(value);
          addTearDown(() => value.dispose());
        },
      ))));

      // This is needed to kick-off the rendering of the JS Map flutter widget
      await tester.pump();
      final GoogleMapController controller = await controllerCompleter.future;

      await tester.pump();
      verify(tileProviders[0].getTile(any, any, any));
      verify(tileProviders[1].getTile(any, any, any));

      await controller.clearTileCache(tileOverlays[0].tileOverlayId);

      await tester.pump();
      verify(tileProviders[0].getTile(any, any, any));
      verifyNoMoreInteractions(tileProviders[1]);
    });
  });
}
