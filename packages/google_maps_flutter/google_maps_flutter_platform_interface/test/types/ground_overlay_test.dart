// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' show hashValues;

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_flutter_platform_interface/src/types/ground_overlay.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ground overlay id tests', () {
    test('equality', () async {
      const GroundOverlayId id1 = GroundOverlayId('1');
      const GroundOverlayId id2 = GroundOverlayId('1');
      const GroundOverlayId id3 = GroundOverlayId('2');
      expect(id1, id2);
      expect(id1, isNot(id3));
    });

    test('toString', () async {
      const GroundOverlayId id1 = GroundOverlayId('1');
      expect(id1.toString(), 'GroundOverlayId(1)');
    });
  });

  group('ground overlay tests', () {
    test('toJson returns correct format', () async {
      const GroundOverlay groundOverlay = GroundOverlay(
          groundOverlayId: GroundOverlayId('id'),
          image: BitmapDescriptor.defaultMarker,
          anchorU: 0.75,
          anchorV: 0.5,
          bearing: 2,
          isClickable: true,
          position: LatLng(30, 50),
          width: 2,
          transparency: 0.7,
          isVisible: true,
          zIndex: 5);
      final Object json = groundOverlay.toJson();

      expect(json, <String, Object>{
        'groundOverlayId': 'id',
        'image': BitmapDescriptor.defaultMarker.toJson(),
        'anchorU': moreOrLessEquals(0.75),
        'anchorV': moreOrLessEquals(0.5),
        'bearing': 2,
        'isClickable': true,
        'position': LatLng(30, 50).toJson(),
        'width': 2,
        'transparency': moreOrLessEquals(0.7),
        'isVisible': true,
        'zIndex': 5,
      });
    });

    test('invalid transparency throws', () async {
      expect(
          () => GroundOverlay(
              groundOverlayId: GroundOverlayId('id'),
              image: BitmapDescriptor.defaultMarker,
              transparency: -0.1),
          throwsAssertionError);
      expect(
          () => GroundOverlay(
              groundOverlayId: GroundOverlayId('id2'),
              image: BitmapDescriptor.defaultMarker,
              transparency: 1.2),
          throwsAssertionError);
    });

    test('equality', () async {
      const GroundOverlay groundOverlay1 = GroundOverlay(
          groundOverlayId: GroundOverlayId('id'),
          image: BitmapDescriptor.defaultMarker,
          anchorU: 0.75,
          anchorV: 0.5,
          bearing: 2,
          isClickable: true,
          position: LatLng(30, 50),
          width: 2,
          transparency: 0.7,
          isVisible: true,
          zIndex: 5);
      const GroundOverlay groundOverlaySameValues = GroundOverlay(
          groundOverlayId: GroundOverlayId('id'),
          image: BitmapDescriptor.defaultMarker,
          anchorU: 0.75,
          anchorV: 0.5,
          bearing: 2,
          isClickable: true,
          position: LatLng(30, 50),
          width: 2,
          transparency: 0.7,
          isVisible: true,
          zIndex: 5);
      const GroundOverlay groundOverlayDifferentId = GroundOverlay(
          groundOverlayId: GroundOverlayId('id2'),
          image: BitmapDescriptor.defaultMarker,
          anchorU: 0.75,
          anchorV: 0.5,
          bearing: 2,
          isClickable: true,
          position: LatLng(30, 50),
          width: 2,
          transparency: 0.7,
          isVisible: true,
          zIndex: 5);
      expect(groundOverlay1, groundOverlaySameValues);
      expect(groundOverlay1, isNot(groundOverlayDifferentId));
    });

    test('clone', () async {
      // Set non-default values for every parameter.
      const GroundOverlay groundOverlay = GroundOverlay(
          groundOverlayId: GroundOverlayId('id'),
          image: BitmapDescriptor.defaultMarker,
          anchorU: 0.75,
          anchorV: 0.5,
          bearing: 2,
          isClickable: true,
          position: LatLng(30, 50),
          width: 2,
          transparency: 0.7,
          isVisible: true,
          zIndex: 5);
      expect(groundOverlay, groundOverlay.clone());
    });

    test('hashCode', () async {
      const GroundOverlay groundOverlay = GroundOverlay(
          groundOverlayId: GroundOverlayId('id'),
          image: BitmapDescriptor.defaultMarker,
          anchorU: 0.75,
          anchorV: 0.5,
          bearing: 2,
          isClickable: true,
          position: LatLng(30, 50),
          width: 2,
          transparency: 0.7,
          isVisible: true,
          zIndex: 5);

      expect(
          groundOverlay.hashCode,
          hashValues(
              groundOverlay.groundOverlayId,
              groundOverlay.image,
              groundOverlay.anchorU,
              groundOverlay.anchorV,
              groundOverlay.bearing,
              groundOverlay.isClickable,
              groundOverlay.position,
              groundOverlay.width,
              groundOverlay.height,
              groundOverlay.positionFromBounds,
              groundOverlay.transparency,
              groundOverlay.isVisible,
              groundOverlay.zIndex));
    });
  });
}
