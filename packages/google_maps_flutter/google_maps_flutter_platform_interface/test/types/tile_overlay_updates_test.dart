// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' show hashValues, hashList;
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/src/types/utils/tile_overlay.dart';
import 'package:google_maps_flutter_platform_interface/src/types/tile_overlay_updates.dart';
import 'package:google_maps_flutter_platform_interface/src/types/tile_overlay.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('tile overlay updates tests', () {
    test('Correctly set toRemove, toAdd and toChange', () async {
      final TileOverlay to1 = TileOverlay(tileOverlayId: TileOverlayId('id1'));
      final TileOverlay to2 = TileOverlay(tileOverlayId: TileOverlayId('id2'));
      final TileOverlay to3 = TileOverlay(tileOverlayId: TileOverlayId('id3'));
      final TileOverlay to3Changed =
          TileOverlay(tileOverlayId: TileOverlayId('id3'), transparency: 0.5);
      final TileOverlay to4 = TileOverlay(tileOverlayId: TileOverlayId('id4'));
      final Set<TileOverlay> previous = Set.from(<TileOverlay>[to1, to2, to3]);
      final Set<TileOverlay> current =
          Set.from(<TileOverlay>[to2, to3Changed, to4]);
      final TileOverlayUpdates updates =
          TileOverlayUpdates.from(previous, current);

      final Set<TileOverlayId> toRemove =
          Set.from(<TileOverlayId>[TileOverlayId('id1')]);
      expect(updates.tileOverlayIdsToRemove, toRemove);

      final Set<TileOverlay> toAdd = Set.from(<TileOverlay>[to4]);
      expect(updates.tileOverlaysToAdd, toAdd);

      final Set<TileOverlay> toChange = Set.from(<TileOverlay>[to3Changed]);
      expect(updates.tileOverlaysToChange, toChange);
    });

    test('toJson', () async {
      final TileOverlay to1 = TileOverlay(tileOverlayId: TileOverlayId('id1'));
      final TileOverlay to2 = TileOverlay(tileOverlayId: TileOverlayId('id2'));
      final TileOverlay to3 = TileOverlay(tileOverlayId: TileOverlayId('id3'));
      final TileOverlay to3Changed =
          TileOverlay(tileOverlayId: TileOverlayId('id3'), transparency: 0.5);
      final TileOverlay to4 = TileOverlay(tileOverlayId: TileOverlayId('id4'));
      final Set<TileOverlay> previous = Set.from(<TileOverlay>[to1, to2, to3]);
      final Set<TileOverlay> current =
          Set.from(<TileOverlay>[to2, to3Changed, to4]);
      final TileOverlayUpdates updates =
          TileOverlayUpdates.from(previous, current);

      final Map<String, dynamic> json = updates.toJson();
      expect(json, <String, dynamic>{
        'tileOverlaysToAdd': serializeTileOverlaySet(updates.tileOverlaysToAdd),
        'tileOverlaysToChange':
            serializeTileOverlaySet(updates.tileOverlaysToChange),
        'tileOverlayIdsToRemove': updates.tileOverlayIdsToRemove
            .map<dynamic>((TileOverlayId m) => m.value)
            .toList()
      });
    });

    test('equality', () async {
      final TileOverlay to1 = TileOverlay(tileOverlayId: TileOverlayId('id1'));
      final TileOverlay to2 = TileOverlay(tileOverlayId: TileOverlayId('id2'));
      final TileOverlay to3 = TileOverlay(tileOverlayId: TileOverlayId('id3'));
      final TileOverlay to3Changed =
          TileOverlay(tileOverlayId: TileOverlayId('id3'), transparency: 0.5);
      final TileOverlay to4 = TileOverlay(tileOverlayId: TileOverlayId('id4'));
      final Set<TileOverlay> previous = Set.from(<TileOverlay>[to1, to2, to3]);
      final Set<TileOverlay> current1 =
          Set.from(<TileOverlay>[to2, to3Changed, to4]);
      final Set<TileOverlay> current2 =
          Set.from(<TileOverlay>[to2, to3Changed, to4]);
      final Set<TileOverlay> current3 = Set.from(<TileOverlay>[to2, to4]);
      final TileOverlayUpdates updates1 =
          TileOverlayUpdates.from(previous, current1);
      final TileOverlayUpdates updates2 =
          TileOverlayUpdates.from(previous, current2);
      final TileOverlayUpdates updates3 =
          TileOverlayUpdates.from(previous, current3);
      expect(updates1, updates2);
      expect(updates1, isNot(updates3));
    });

    test('hashCode', () async {
      final TileOverlay to1 = TileOverlay(tileOverlayId: TileOverlayId('id1'));
      final TileOverlay to2 = TileOverlay(tileOverlayId: TileOverlayId('id2'));
      final TileOverlay to3 = TileOverlay(tileOverlayId: TileOverlayId('id3'));
      final TileOverlay to3Changed =
          TileOverlay(tileOverlayId: TileOverlayId('id3'), transparency: 0.5);
      final TileOverlay to4 = TileOverlay(tileOverlayId: TileOverlayId('id4'));
      final Set<TileOverlay> previous = Set.from(<TileOverlay>[to1, to2, to3]);
      final Set<TileOverlay> current =
          Set.from(<TileOverlay>[to2, to3Changed, to4]);
      final TileOverlayUpdates updates =
          TileOverlayUpdates.from(previous, current);
      expect(
          updates.hashCode,
          hashValues(
              hashList(updates.tileOverlaysToAdd),
              hashList(updates.tileOverlayIdsToRemove),
              hashList(updates.tileOverlaysToChange)));
    });

    test('toString', () async {
      final TileOverlay to1 = TileOverlay(tileOverlayId: TileOverlayId('id1'));
      final TileOverlay to2 = TileOverlay(tileOverlayId: TileOverlayId('id2'));
      final TileOverlay to3 = TileOverlay(tileOverlayId: TileOverlayId('id3'));
      final TileOverlay to3Changed =
          TileOverlay(tileOverlayId: TileOverlayId('id3'), transparency: 0.5);
      final TileOverlay to4 = TileOverlay(tileOverlayId: TileOverlayId('id4'));
      final Set<TileOverlay> previous = Set.from(<TileOverlay>[to1, to2, to3]);
      final Set<TileOverlay> current =
          Set.from(<TileOverlay>[to2, to3Changed, to4]);
      final TileOverlayUpdates updates =
          TileOverlayUpdates.from(previous, current);
      expect(
          updates.toString(),
          'TileOverlayUpdates(${updates.tileOverlaysToAdd}, '
          '${updates.tileOverlayIdsToRemove}, '
          '${updates.tileOverlaysToChange})');
    });
  });
}
