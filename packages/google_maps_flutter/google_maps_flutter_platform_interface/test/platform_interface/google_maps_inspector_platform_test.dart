// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:mockito/mockito.dart';

void main() {
  // Store the initial instance before any tests change it.
  final GoogleMapsInspectorPlatform? initialInstance =
      GoogleMapsInspectorPlatform.instance;

  test('default instance is null', () {
    expect(initialInstance, isNull);
  });

  test('cannot be implemented with `implements`', () {
    expect(() {
      GoogleMapsInspectorPlatform.instance =
          ImplementsGoogleMapsInspectorPlatform();
    }, throwsA(isInstanceOf<AssertionError>()));
  });

  test('can be implement with `extends`', () {
    GoogleMapsInspectorPlatform.instance = ExtendsGoogleMapsInspectorPlatform();
  });
}

class ImplementsGoogleMapsInspectorPlatform extends Mock
    implements GoogleMapsInspectorPlatform {}

class ExtendsGoogleMapsInspectorPlatform extends GoogleMapsInspectorPlatform {}
