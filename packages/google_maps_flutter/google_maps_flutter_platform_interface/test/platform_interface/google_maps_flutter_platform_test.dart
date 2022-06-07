// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Store the initial instance before any tests change it.
  final GoogleMapsFlutterPlatform initialInstance =
      GoogleMapsFlutterPlatform.instance;

  group('$GoogleMapsFlutterPlatform', () {
    test('$MethodChannelGoogleMapsFlutter() is the default instance', () {
      expect(initialInstance, isInstanceOf<MethodChannelGoogleMapsFlutter>());
    });

    test('Cannot be implemented with `implements`', () {
      expect(() {
        GoogleMapsFlutterPlatform.instance =
            ImplementsGoogleMapsFlutterPlatform();
      }, throwsA(isInstanceOf<AssertionError>()));
    });

    test('Can be mocked with `implements`', () {
      final GoogleMapsFlutterPlatformMock mock =
          GoogleMapsFlutterPlatformMock();
      GoogleMapsFlutterPlatform.instance = mock;
    });

    test('Can be extended', () {
      GoogleMapsFlutterPlatform.instance = ExtendsGoogleMapsFlutterPlatform();
    });

    test(
      'default implementation of `buildViewWithTextDirection` delegates to `buildView`',
      () {
        final GoogleMapsFlutterPlatform platform =
            BuildViewGoogleMapsFlutterPlatform();
        expect(
          platform.buildViewWithTextDirection(
            0,
            (_) {},
            initialCameraPosition:
                const CameraPosition(target: LatLng(0.0, 0.0)),
            textDirection: TextDirection.ltr,
          ),
          isA<Text>(),
        );
      },
    );
  });
}

class GoogleMapsFlutterPlatformMock extends Mock
    with MockPlatformInterfaceMixin
    implements GoogleMapsFlutterPlatform {}

class ImplementsGoogleMapsFlutterPlatform extends Mock
    implements GoogleMapsFlutterPlatform {}

class ExtendsGoogleMapsFlutterPlatform extends GoogleMapsFlutterPlatform {}

class BuildViewGoogleMapsFlutterPlatform extends GoogleMapsFlutterPlatform {
  @override
  Widget buildView(
    int creationId,
    PlatformViewCreatedCallback onPlatformViewCreated, {
    required CameraPosition initialCameraPosition,
    Set<Marker> markers = const <Marker>{},
    Set<Polygon> polygons = const <Polygon>{},
    Set<Polyline> polylines = const <Polyline>{},
    Set<Circle> circles = const <Circle>{},
    Set<TileOverlay> tileOverlays = const <TileOverlay>{},
    Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers =
        const <Factory<OneSequenceGestureRecognizer>>{},
    Map<String, dynamic> mapOptions = const <String, dynamic>{},
  }) {
    return const Text('');
  }
}
