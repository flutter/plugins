// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:google_maps_flutter_platform_interface/src/method_channel/method_channel_google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$GoogleMapsFlutterPlatform', () {
    test('$MethodChannelGoogleMapsFlutter() is the default instance', () {
      expect(GoogleMapsFlutterPlatform.instance,
          isInstanceOf<MethodChannelGoogleMapsFlutter>());
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
  });
}

class GoogleMapsFlutterPlatformMock extends Mock
    with MockPlatformInterfaceMixin
    implements GoogleMapsFlutterPlatform {}

class ImplementsGoogleMapsFlutterPlatform extends Mock
    implements GoogleMapsFlutterPlatform {}

class ExtendsGoogleMapsFlutterPlatform extends GoogleMapsFlutterPlatform {}
