// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

class _TestTileProvider extends TileProvider {
  @override
  Future<Tile> getTile(int x, int y, int? zoom) async {
    return Tile(0, 0, null);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('tile overlay id tests', () {
    test('equality', () async {
      const TileOverlayId id1 = TileOverlayId('1');
      const TileOverlayId id2 = TileOverlayId('1');
      const TileOverlayId id3 = TileOverlayId('2');
      expect(id1, id2);
      expect(id1, isNot(id3));
    });

    test('toString', () async {
      const TileOverlayId id1 = TileOverlayId('1');
      expect(id1.toString(), 'TileOverlayId(1)');
    });
  });

  group('tile overlay tests', () {
    test('toJson returns correct format', () async {
      const TileOverlay tileOverlay = TileOverlay(
          tileOverlayId: TileOverlayId('id'),
          fadeIn: false,
          tileProvider: null,
          transparency: 0.1,
          zIndex: 1,
          visible: false,
          tileSize: 128);
      final Object json = tileOverlay.toJson();
      expect(json, <String, Object>{
        'tileOverlayId': 'id',
        'fadeIn': false,
        'transparency': moreOrLessEquals(0.1),
        'zIndex': 1,
        'visible': false,
        'tileSize': 128,
      });
    });

    test('invalid transparency throws', () async {
      expect(
          () => TileOverlay(
              tileOverlayId: const TileOverlayId('id1'), transparency: -0.1),
          throwsAssertionError);
      expect(
          () => TileOverlay(
              tileOverlayId: const TileOverlayId('id2'), transparency: 1.2),
          throwsAssertionError);
    });

    test('equality', () async {
      final TileProvider tileProvider = _TestTileProvider();
      final TileOverlay tileOverlay1 = TileOverlay(
          tileOverlayId: TileOverlayId('id1'),
          fadeIn: false,
          tileProvider: tileProvider,
          transparency: 0.1,
          zIndex: 1,
          visible: false,
          tileSize: 128);
      final TileOverlay tileOverlaySameValues = TileOverlay(
          tileOverlayId: TileOverlayId('id1'),
          fadeIn: false,
          tileProvider: tileProvider,
          transparency: 0.1,
          zIndex: 1,
          visible: false,
          tileSize: 128);
      final TileOverlay tileOverlayDifferentId = TileOverlay(
          tileOverlayId: TileOverlayId('id2'),
          fadeIn: false,
          tileProvider: tileProvider,
          transparency: 0.1,
          zIndex: 1,
          visible: false,
          tileSize: 128);
      final TileOverlay tileOverlayDifferentProvider = TileOverlay(
          tileOverlayId: TileOverlayId('id1'),
          fadeIn: false,
          tileProvider: null,
          transparency: 0.1,
          zIndex: 1,
          visible: false,
          tileSize: 128);
      expect(tileOverlay1, tileOverlaySameValues);
      expect(tileOverlay1, isNot(tileOverlayDifferentId));
      expect(tileOverlay1, isNot(tileOverlayDifferentProvider));
    });

    test('clone', () async {
      final TileProvider tileProvider = _TestTileProvider();
      // Set non-default values for every parameter.
      final TileOverlay tileOverlay = TileOverlay(
          tileOverlayId: TileOverlayId('id1'),
          fadeIn: false,
          tileProvider: tileProvider,
          transparency: 0.1,
          zIndex: 1,
          visible: false,
          tileSize: 128);
      expect(tileOverlay, tileOverlay.clone());
    });

    test('hashCode', () async {
      final TileProvider tileProvider = _TestTileProvider();
      const TileOverlayId id = TileOverlayId('id1');
      final TileOverlay tileOverlay = TileOverlay(
          tileOverlayId: id,
          fadeIn: false,
          tileProvider: tileProvider,
          transparency: 0.1,
          zIndex: 1,
          visible: false,
          tileSize: 128);
      expect(
          tileOverlay.hashCode,
          Object.hash(
              tileOverlay.tileOverlayId,
              tileOverlay.fadeIn,
              tileOverlay.tileProvider,
              tileOverlay.transparency,
              tileOverlay.zIndex,
              tileOverlay.visible,
              tileOverlay.tileSize));
    });
  });
}
