// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_flutter_platform_interface/src/types/utils/maps_object.dart';

import 'test_maps_object.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('keyByMapsObjectId', () async {
    const MapsObjectId<TestMapsObject> id1 = MapsObjectId<TestMapsObject>('1');
    const MapsObjectId<TestMapsObject> id2 = MapsObjectId<TestMapsObject>('2');
    const MapsObjectId<TestMapsObject> id3 = MapsObjectId<TestMapsObject>('3');
    const TestMapsObject object1 = TestMapsObject(id1);
    const TestMapsObject object2 = TestMapsObject(id2, data: 2);
    const TestMapsObject object3 = TestMapsObject(id3);
    expect(
        keyByMapsObjectId(<TestMapsObject>{object1, object2, object3}),
        <MapsObjectId<TestMapsObject>, TestMapsObject>{
          id1: object1,
          id2: object2,
          id3: object3,
        });
  });

  test('serializeMapsObjectSet', () async {
    const MapsObjectId<TestMapsObject> id1 = MapsObjectId<TestMapsObject>('1');
    const MapsObjectId<TestMapsObject> id2 = MapsObjectId<TestMapsObject>('2');
    const MapsObjectId<TestMapsObject> id3 = MapsObjectId<TestMapsObject>('3');
    const TestMapsObject object1 = TestMapsObject(id1);
    const TestMapsObject object2 = TestMapsObject(id2, data: 2);
    const TestMapsObject object3 = TestMapsObject(id3);
    expect(
        serializeMapsObjectSet(<TestMapsObject>{object1, object2, object3}),
        <Map<String, Object>>[
          {'id': '1'},
          {'id': '2'},
          {'id': '3'}
        ]);
  });

  test('MarkerId equality should preserve inheritance and only check value',
      () async {
    const String value = 'id123';
    const MarkerId markerId = MarkerId(value);
    const TestMapsObjectId<Marker> customMarkerId =
        TestMapsObjectId<Marker>(value);
    expect(customMarkerId, equals(markerId));
  });
}
