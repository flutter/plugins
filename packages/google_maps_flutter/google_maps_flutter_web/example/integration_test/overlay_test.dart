// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps/google_maps.dart' as gmaps;
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
import 'package:integration_test/integration_test.dart';

import 'resources/tile16_base64.dart';

class NoTileProvider implements TileProvider {
  const NoTileProvider();

  @override
  Future<Tile> getTile(int x, int y, int? zoom) async => TileProvider.noTile;
}

class TestTileProvider implements TileProvider {
  const TestTileProvider();

  @override
  Future<Tile> getTile(int x, int y, int? zoom) async =>
      Tile(16, 16, const Base64Decoder().convert(tile16Base64));
}

/// Test Overlays
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('TileOverlayController', () {
    const TileOverlayId id = TileOverlayId('');
    late TileOverlayController controller;

    setUp(() {
      controller = TileOverlayController();
    });

    testWidgets('minimal initialization', (WidgetTester tester) async {
      controller.update(const TileOverlay(tileOverlayId: id));

      final gmaps.Size size = controller.gmMapType.tileSize!;
      expect(size.width, TileOverlayController.logicalTileSize);
      expect(size.height, TileOverlayController.logicalTileSize);
      expect(controller.gmMapType.getTile!(gmaps.Point(0, 0), 0, html.document),
          null);
    });

    testWidgets('produces image tiles', (WidgetTester tester) async {
      controller.update(const TileOverlay(
        tileOverlayId: id,
        tileProvider: TestTileProvider(),
      ));

      final html.ImageElement img =
          controller.gmMapType.getTile!(gmaps.Point(0, 0), 0, html.document)!
              as html.ImageElement;
      expect(img.hidden, true);
      expect(img.naturalWidth, 0);
      expect(img.naturalHeight, 0);

      // `onLoad` is fired when `src` is set; then `decode` is fired once the
      // image has been decoded. Some of our assertions test properties set in
      // the overlay controller's `decode` handler. Those are guaranteed to run
      // first since the overlay controller sets `src`, which precipitates
      // `onLoad` here, synchronously before it initiates `decode`. Technically
      // the `decode` call here could otherwise have a side effect of initiating
      // the decoding, but that shouldn't affect correctness, though it may let
      // a performance regression slip by should the impl let the browser
      // attempt to paint a tile before it is decoded.
      await img.onLoad.first;
      await img.decode();

      expect(img.hidden, false);
      expect(img.naturalWidth, 16);
      expect(img.naturalHeight, 16);
    });

    testWidgets('update', (WidgetTester tester) async {
      controller.update(const TileOverlay(
        tileOverlayId: id,
        tileProvider: NoTileProvider(),
      ));

      {
        final html.ImageElement img =
            controller.gmMapType.getTile!(gmaps.Point(0, 0), 0, html.document)!
                as html.ImageElement;
        await null; // let `getTile` `then` complete
        expect(img.src, isEmpty);
      }

      controller.update(const TileOverlay(
        tileOverlayId: id,
        tileProvider: TestTileProvider(),
      ));

      {
        final html.ImageElement img =
            controller.gmMapType.getTile!(gmaps.Point(0, 0), 0, html.document)!
                as html.ImageElement;
        await null; // let `getTile` `then` complete
        expect(img.src, isNotEmpty);
      }

      // Also make sure updating the tileProvider to null works.
      controller.update(const TileOverlay(tileOverlayId: id));

      {
        expect(
            controller.gmMapType.getTile!(gmaps.Point(0, 0), 0, html.document),
            null);
      }
    });
  });
}
