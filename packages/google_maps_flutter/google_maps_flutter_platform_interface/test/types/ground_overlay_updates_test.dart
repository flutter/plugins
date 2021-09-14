// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' show hashValues, hashList;

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_flutter_platform_interface/src/types/ground_overlay.dart';
import 'package:google_maps_flutter_platform_interface/src/types/ground_overlay_updates.dart';
import 'package:google_maps_flutter_platform_interface/src/types/utils/ground_overlay.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ground overlay updates tests', () {
    test('Correctly set toRemove, toAdd and toChange', () async {
      const GroundOverlay go1 = GroundOverlay(
        groundOverlayId: GroundOverlayId('id1'),
        image: BitmapDescriptor.defaultMarker,
        position: LatLng(0, 0),
        width: 100,
      );
      const GroundOverlay go2 = GroundOverlay(
        groundOverlayId: GroundOverlayId('id2'),
        image: BitmapDescriptor.defaultMarker,
        position: LatLng(0, 0),
        width: 100,
      );
      const GroundOverlay go3 = GroundOverlay(
        groundOverlayId: GroundOverlayId('id3'),
        image: BitmapDescriptor.defaultMarker,
        position: LatLng(0, 0),
        width: 100,
      );
      const GroundOverlay go3Changed = GroundOverlay(
        groundOverlayId: GroundOverlayId('id3'),
        transparency: 0.5,
        image: BitmapDescriptor.defaultMarker,
        position: LatLng(0, 0),
        width: 100,
      );
      const GroundOverlay go4 = GroundOverlay(
        groundOverlayId: GroundOverlayId('id4'),
        image: BitmapDescriptor.defaultMarker,
        position: LatLng(0, 0),
        width: 100,
      );
      final Set<GroundOverlay> previous =
          Set.from(<GroundOverlay>[go1, go2, go3]);
      final Set<GroundOverlay> current =
          Set.from(<GroundOverlay>[go2, go3Changed, go4]);
      final GroundOverlayUpdates updates =
          GroundOverlayUpdates.from(previous, current);

      final Set<GroundOverlayId> toRemove =
          Set.from(<GroundOverlayId>[const GroundOverlayId('id1')]);
      expect(updates.groundOverlayIdsToRemove, toRemove);

      final Set<GroundOverlay> toAdd = Set.from(<GroundOverlay>[go4]);
      expect(updates.groundOverlaysToAdd, toAdd);

      final Set<GroundOverlay> toChange = Set.from(<GroundOverlay>[go3Changed]);
      expect(updates.groundOverlaysToChange, toChange);
    });

    test('toJson', () async {
      const GroundOverlay go1 = GroundOverlay(
        groundOverlayId: GroundOverlayId('id1'),
        image: BitmapDescriptor.defaultMarker,
        position: LatLng(0, 0),
        width: 100,
      );
      const GroundOverlay go2 = GroundOverlay(
        groundOverlayId: GroundOverlayId('id2'),
        image: BitmapDescriptor.defaultMarker,
        position: LatLng(0, 0),
        width: 100,
      );
      const GroundOverlay go3 = GroundOverlay(
        groundOverlayId: GroundOverlayId('id3'),
        image: BitmapDescriptor.defaultMarker,
        position: LatLng(0, 0),
        width: 100,
      );
      const GroundOverlay go3Changed = GroundOverlay(
        groundOverlayId: GroundOverlayId('id3'),
        transparency: 0.5,
        image: BitmapDescriptor.defaultMarker,
        position: LatLng(0, 0),
        width: 100,
      );
      const GroundOverlay go4 = GroundOverlay(
        groundOverlayId: GroundOverlayId('id4'),
        image: BitmapDescriptor.defaultMarker,
        position: LatLng(0, 0),
        width: 100,
      );
      final Set<GroundOverlay> previous =
          Set.from(<GroundOverlay>[go1, go2, go3]);
      final Set<GroundOverlay> current =
          Set.from(<GroundOverlay>[go2, go3Changed, go4]);
      final GroundOverlayUpdates updates =
          GroundOverlayUpdates.from(previous, current);

      final Object json = updates.toJson();
      expect(json, <String, Object>{
        'groundOverlaysToAdd':
            serializeGroundOverlaySet(updates.groundOverlaysToAdd),
        'groundOverlaysToChange':
            serializeGroundOverlaySet(updates.groundOverlaysToChange),
        'groundOverlayIdsToRemove': updates.groundOverlayIdsToRemove
            .map<String>((GroundOverlayId m) => m.value)
            .toList()
      });
    });

    test('equality', () async {
      const GroundOverlay go1 = GroundOverlay(
        groundOverlayId: GroundOverlayId('id1'),
        image: BitmapDescriptor.defaultMarker,
        position: LatLng(0, 0),
        width: 100,
      );
      const GroundOverlay go2 = GroundOverlay(
        groundOverlayId: GroundOverlayId('id2'),
        image: BitmapDescriptor.defaultMarker,
        position: LatLng(0, 0),
        width: 100,
      );
      const GroundOverlay go3 = GroundOverlay(
        groundOverlayId: GroundOverlayId('id3'),
        image: BitmapDescriptor.defaultMarker,
        position: LatLng(0, 0),
        width: 100,
      );
      const GroundOverlay go3Changed = GroundOverlay(
        groundOverlayId: GroundOverlayId('id3'),
        transparency: 0.5,
        image: BitmapDescriptor.defaultMarker,
        position: LatLng(0, 0),
        width: 100,
      );
      const GroundOverlay go4 = GroundOverlay(
        groundOverlayId: GroundOverlayId('id4'),
        image: BitmapDescriptor.defaultMarker,
        position: LatLng(0, 0),
        width: 100,
      );
      final Set<GroundOverlay> previous =
          Set.from(<GroundOverlay>[go1, go2, go3]);
      final Set<GroundOverlay> current1 =
          Set.from(<GroundOverlay>[go2, go3Changed, go4]);
      final Set<GroundOverlay> current2 =
          Set.from(<GroundOverlay>[go2, go3Changed, go4]);
      final Set<GroundOverlay> current3 = Set.from(<GroundOverlay>[go2, go4]);
      final GroundOverlayUpdates updates1 =
          GroundOverlayUpdates.from(previous, current1);
      final GroundOverlayUpdates updates2 =
          GroundOverlayUpdates.from(previous, current2);
      final GroundOverlayUpdates updates3 =
          GroundOverlayUpdates.from(previous, current3);
      expect(updates1, updates2);
      expect(updates1, isNot(updates3));
    });

    test('hashCode', () async {
      const GroundOverlay go1 = GroundOverlay(
        groundOverlayId: GroundOverlayId('id1'),
        image: BitmapDescriptor.defaultMarker,
        position: LatLng(0, 0),
        width: 100,
      );
      const GroundOverlay go2 = GroundOverlay(
        groundOverlayId: GroundOverlayId('id2'),
        image: BitmapDescriptor.defaultMarker,
        position: LatLng(0, 0),
        width: 100,
      );
      const GroundOverlay go3 = GroundOverlay(
        groundOverlayId: GroundOverlayId('id3'),
        image: BitmapDescriptor.defaultMarker,
        position: LatLng(0, 0),
        width: 100,
      );
      const GroundOverlay go3Changed = GroundOverlay(
        groundOverlayId: GroundOverlayId('id3'),
        transparency: 0.5,
        image: BitmapDescriptor.defaultMarker,
        position: LatLng(0, 0),
        width: 100,
      );
      const GroundOverlay go4 = GroundOverlay(
        groundOverlayId: GroundOverlayId('id4'),
        image: BitmapDescriptor.defaultMarker,
        position: LatLng(0, 0),
        width: 100,
      );
      final Set<GroundOverlay> previous =
          Set.from(<GroundOverlay>[go1, go2, go3]);
      final Set<GroundOverlay> current =
          Set.from(<GroundOverlay>[go2, go3Changed, go4]);
      final GroundOverlayUpdates updates =
          GroundOverlayUpdates.from(previous, current);
      expect(
          updates.hashCode,
          hashValues(
              hashList(updates.groundOverlaysToAdd),
              hashList(updates.groundOverlayIdsToRemove),
              hashList(updates.groundOverlaysToChange)));
    });

    test('toString', () async {
      const GroundOverlay go1 = GroundOverlay(
        groundOverlayId: GroundOverlayId('id1'),
        image: BitmapDescriptor.defaultMarker,
        position: LatLng(0, 0),
        width: 100,
      );
      const GroundOverlay go2 = GroundOverlay(
        groundOverlayId: GroundOverlayId('id2'),
        image: BitmapDescriptor.defaultMarker,
        position: LatLng(0, 0),
        width: 100,
      );
      const GroundOverlay go3 = GroundOverlay(
        groundOverlayId: GroundOverlayId('id3'),
        image: BitmapDescriptor.defaultMarker,
        position: LatLng(0, 0),
        width: 100,
      );
      const GroundOverlay go3Changed = GroundOverlay(
        groundOverlayId: GroundOverlayId('id3'),
        transparency: 0.5,
        image: BitmapDescriptor.defaultMarker,
        position: LatLng(0, 0),
        width: 100,
      );
      const GroundOverlay go4 = GroundOverlay(
        groundOverlayId: GroundOverlayId('id4'),
        image: BitmapDescriptor.defaultMarker,
        position: LatLng(0, 0),
        width: 100,
      );
      final Set<GroundOverlay> previous =
          Set.from(<GroundOverlay>[go1, go2, go3]);
      final Set<GroundOverlay> current =
          Set.from(<GroundOverlay>[go2, go3Changed, go4]);
      final GroundOverlayUpdates updates =
          GroundOverlayUpdates.from(previous, current);
      expect(
          updates.toString(),
          'GroundOverlayUpdates(add: ${updates.groundOverlaysToAdd}, '
          'remove: ${updates.groundOverlayIdsToRemove}, '
          'change: ${updates.groundOverlaysToChange})');
    });
  });
}
