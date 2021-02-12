// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' show hashValues;
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('tile overlay id tests', () {
    test('equality', () async {
      final TileOverlayId id1 = TileOverlayId('1');
      final TileOverlayId id2 = TileOverlayId('1');
      final TileOverlayId id3 = TileOverlayId('2');
      expect(id1, id2);
      expect(id1, isNot(id3));
    });

    test('toString', () async {
      final TileOverlayId id1 = TileOverlayId('1');
      expect(id1.toString(), 'TileOverlayId(1)');
    });
  });

  group('tile overlay tests', () {
    test('toJson returns correct format', () async {
      final TileOverlay tileOverlay = TileOverlay(
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
              tileOverlayId: TileOverlayId('id1'), transparency: -0.1),
          throwsAssertionError);
      expect(
          () => TileOverlay(
              tileOverlayId: TileOverlayId('id2'), transparency: 1.2),
          throwsAssertionError);
    });

    test('equality', () async {
      final TileOverlay tileOverlay1 = TileOverlay(
          tileOverlayId: TileOverlayId('id1'),
          fadeIn: false,
          tileProvider: null,
          transparency: 0.1,
          zIndex: 1,
          visible: false,
          tileSize: 128);
      final TileOverlay tileOverlay2 = TileOverlay(
          tileOverlayId: TileOverlayId('id1'),
          fadeIn: false,
          tileProvider: null,
          transparency: 0.1,
          zIndex: 1,
          visible: false,
          tileSize: 128);
      final TileOverlay tileOverlay3 = TileOverlay(
          tileOverlayId: TileOverlayId('id2'),
          fadeIn: false,
          tileProvider: null,
          transparency: 0.1,
          zIndex: 1,
          visible: false,
          tileSize: 128);
      expect(tileOverlay1, tileOverlay2);
      expect(tileOverlay1, isNot(tileOverlay3));
    });

    test('hashCode', () async {
      TileOverlayId id = TileOverlayId('id1');
      final TileOverlay tileOverlay = TileOverlay(
          tileOverlayId: id,
          fadeIn: false,
          tileProvider: null,
          transparency: 0.1,
          zIndex: 1,
          visible: false,
          tileSize: 128);
      expect(
          tileOverlay.hashCode,
          hashValues(
              tileOverlay.tileOverlayId,
              tileOverlay.fadeIn,
              tileOverlay.transparency,
              tileOverlay.zIndex,
              tileOverlay.visible,
              tileOverlay.tileSize));
    });
  });
}
