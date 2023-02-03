// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';

import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$Marker', () {
    test('constructor defaults', () {
      const Marker marker = Marker(markerId: MarkerId('ABC123'));

      expect(marker.alpha, equals(1.0));
      expect(marker.anchor, equals(const Offset(0.5, 1.0)));
      expect(marker.consumeTapEvents, equals(false));
      expect(marker.draggable, equals(false));
      expect(marker.flat, equals(false));
      expect(marker.icon, equals(BitmapDescriptor.defaultMarker));
      expect(marker.infoWindow, equals(InfoWindow.noText));
      expect(marker.position, equals(const LatLng(0.0, 0.0)));
      expect(marker.rotation, equals(0.0));
      expect(marker.visible, equals(true));
      expect(marker.zIndex, equals(0.0));
      expect(marker.onTap, equals(null));
      expect(marker.onDrag, equals(null));
      expect(marker.onDragStart, equals(null));
      expect(marker.onDragEnd, equals(null));
    });
    test('constructor alpha is >= 0.0 and <= 1.0', () {
      void initWithAlpha(double alpha) {
        Marker(markerId: const MarkerId('ABC123'), alpha: alpha);
      }

      expect(() => initWithAlpha(-0.5), throwsAssertionError);
      expect(() => initWithAlpha(0.0), isNot(throwsAssertionError));
      expect(() => initWithAlpha(0.5), isNot(throwsAssertionError));
      expect(() => initWithAlpha(1.0), isNot(throwsAssertionError));
      expect(() => initWithAlpha(100), throwsAssertionError);
    });

    test('toJson', () {
      final BitmapDescriptor testDescriptor =
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);
      final Marker marker = Marker(
        markerId: const MarkerId('ABC123'),
        alpha: 0.12345,
        anchor: const Offset(100, 100),
        consumeTapEvents: true,
        draggable: true,
        flat: true,
        icon: testDescriptor,
        infoWindow: const InfoWindow(
          title: 'Test title',
          snippet: 'Test snippet',
          anchor: Offset(100, 200),
        ),
        position: const LatLng(50, 50),
        rotation: 100,
        visible: false,
        zIndex: 100,
        onTap: () {},
        onDragStart: (LatLng latLng) {},
        onDrag: (LatLng latLng) {},
        onDragEnd: (LatLng latLng) {},
      );

      final Map<String, Object> json = marker.toJson() as Map<String, Object>;

      expect(json, <String, Object>{
        'markerId': 'ABC123',
        'alpha': 0.12345,
        'anchor': <double>[100, 100],
        'consumeTapEvents': true,
        'draggable': true,
        'flat': true,
        'icon': testDescriptor.toJson(),
        'infoWindow': <String, Object>{
          'title': 'Test title',
          'snippet': 'Test snippet',
          'anchor': <Object>[100.0, 200.0],
        },
        'position': <double>[50, 50],
        'rotation': 100.0,
        'visible': false,
        'zIndex': 100.0,
      });
    });
    test('clone', () {
      const Marker marker = Marker(markerId: MarkerId('ABC123'));
      final Marker clone = marker.clone();

      expect(identical(clone, marker), isFalse);
      expect(clone, equals(marker));
    });
    test('copyWith', () {
      const MarkerId markerId = MarkerId('ABC123');
      const Marker marker = Marker(markerId: markerId);

      final BitmapDescriptor testDescriptor =
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);
      const double testAlphaParam = 0.12345;
      const Offset testAnchorParam = Offset(100, 100);
      final bool testConsumeTapEventsParam = !marker.consumeTapEvents;
      final bool testDraggableParam = !marker.draggable;
      final bool testFlatParam = !marker.flat;
      final BitmapDescriptor testIconParam = testDescriptor;
      const InfoWindow testInfoWindowParam = InfoWindow(title: 'Test');
      const LatLng testPositionParam = LatLng(100, 100);
      const double testRotationParam = 100;
      final bool testVisibleParam = !marker.visible;
      const double testZIndexParam = 100;
      const ClusterManagerId testClusterManagerIdParam =
          ClusterManagerId('DEF123');
      final List<String> log = <String>[];

      final Marker copy = marker.copyWith(
        alphaParam: testAlphaParam,
        anchorParam: testAnchorParam,
        consumeTapEventsParam: testConsumeTapEventsParam,
        draggableParam: testDraggableParam,
        flatParam: testFlatParam,
        iconParam: testIconParam,
        infoWindowParam: testInfoWindowParam,
        positionParam: testPositionParam,
        rotationParam: testRotationParam,
        visibleParam: testVisibleParam,
        zIndexParam: testZIndexParam,
        clusterManagerIdParam: testClusterManagerIdParam,
        onTapParam: () {
          log.add('onTapParam');
        },
        onDragStartParam: (LatLng latLng) {
          log.add('onDragStartParam');
        },
        onDragParam: (LatLng latLng) {
          log.add('onDragParam');
        },
        onDragEndParam: (LatLng latLng) {
          log.add('onDragEndParam');
        },
      );

      expect(copy.markerId, equals(markerId));
      expect(copy.alpha, equals(testAlphaParam));
      expect(copy.anchor, equals(testAnchorParam));
      expect(copy.consumeTapEvents, equals(testConsumeTapEventsParam));
      expect(copy.draggable, equals(testDraggableParam));
      expect(copy.flat, equals(testFlatParam));
      expect(copy.icon, equals(testIconParam));
      expect(copy.infoWindow, equals(testInfoWindowParam));
      expect(copy.position, equals(testPositionParam));
      expect(copy.rotation, equals(testRotationParam));
      expect(copy.visible, equals(testVisibleParam));
      expect(copy.zIndex, equals(testZIndexParam));
      expect(copy.clusterManagerId, equals(testClusterManagerIdParam));

      copy.onTap!();
      expect(log, contains('onTapParam'));

      copy.onDragStart!(const LatLng(0, 1));
      expect(log, contains('onDragStartParam'));

      copy.onDrag!(const LatLng(0, 1));
      expect(log, contains('onDragParam'));

      copy.onDragEnd!(const LatLng(0, 1));
      expect(log, contains('onDragEndParam'));
    });
  });
}
