// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/src/types/maps_object.dart';
import 'package:google_maps_flutter_platform_interface/src/types/maps_object_updates.dart';
import 'package:google_maps_flutter_platform_interface/src/types/utils/maps_object.dart';

import 'test_maps_object.dart';

class TestMapsObjectUpdate extends MapsObjectUpdates<TestMapsObject> {
  TestMapsObjectUpdate.from(
      Set<TestMapsObject> previous, Set<TestMapsObject> current)
      : super.from(previous, current, objectName: 'testObject');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('tile overlay updates tests', () {
    test('Correctly set toRemove, toAdd and toChange', () async {
      const TestMapsObject to1 =
          TestMapsObject(MapsObjectId<TestMapsObject>('id1'));
      const TestMapsObject to2 =
          TestMapsObject(MapsObjectId<TestMapsObject>('id2'));
      const TestMapsObject to3 =
          TestMapsObject(MapsObjectId<TestMapsObject>('id3'));
      const TestMapsObject to3Changed =
          TestMapsObject(MapsObjectId<TestMapsObject>('id3'), data: 2);
      const TestMapsObject to4 =
          TestMapsObject(MapsObjectId<TestMapsObject>('id4'));
      final Set<TestMapsObject> previous = <TestMapsObject>{to1, to2, to3};
      final Set<TestMapsObject> current = <TestMapsObject>{
        to2,
        to3Changed,
        to4
      };
      final TestMapsObjectUpdate updates =
          TestMapsObjectUpdate.from(previous, current);

      final Set<MapsObjectId<TestMapsObject>> toRemove =
          <MapsObjectId<TestMapsObject>>{
        const MapsObjectId<TestMapsObject>('id1')
      };
      expect(updates.objectIdsToRemove, toRemove);

      final Set<TestMapsObject> toAdd = <TestMapsObject>{to4};
      expect(updates.objectsToAdd, toAdd);

      final Set<TestMapsObject> toChange = <TestMapsObject>{to3Changed};
      expect(updates.objectsToChange, toChange);
    });

    test('toJson', () async {
      const TestMapsObject to1 =
          TestMapsObject(MapsObjectId<TestMapsObject>('id1'));
      const TestMapsObject to2 =
          TestMapsObject(MapsObjectId<TestMapsObject>('id2'));
      const TestMapsObject to3 =
          TestMapsObject(MapsObjectId<TestMapsObject>('id3'));
      const TestMapsObject to3Changed =
          TestMapsObject(MapsObjectId<TestMapsObject>('id3'), data: 2);
      const TestMapsObject to4 =
          TestMapsObject(MapsObjectId<TestMapsObject>('id4'));
      final Set<TestMapsObject> previous = <TestMapsObject>{to1, to2, to3};
      final Set<TestMapsObject> current = <TestMapsObject>{
        to2,
        to3Changed,
        to4
      };
      final TestMapsObjectUpdate updates =
          TestMapsObjectUpdate.from(previous, current);

      final Object json = updates.toJson();
      expect(json, <String, Object>{
        'testObjectsToAdd': serializeMapsObjectSet(updates.objectsToAdd),
        'testObjectsToChange': serializeMapsObjectSet(updates.objectsToChange),
        'testObjectIdsToRemove': updates.objectIdsToRemove
            .map<String>((MapsObjectId<TestMapsObject> m) => m.value)
            .toList()
      });
    });

    test('equality', () async {
      const TestMapsObject to1 =
          TestMapsObject(MapsObjectId<TestMapsObject>('id1'));
      const TestMapsObject to2 =
          TestMapsObject(MapsObjectId<TestMapsObject>('id2'));
      const TestMapsObject to3 =
          TestMapsObject(MapsObjectId<TestMapsObject>('id3'));
      const TestMapsObject to3Changed =
          TestMapsObject(MapsObjectId<TestMapsObject>('id3'), data: 2);
      const TestMapsObject to4 =
          TestMapsObject(MapsObjectId<TestMapsObject>('id4'));
      final Set<TestMapsObject> previous = <TestMapsObject>{to1, to2, to3};
      final Set<TestMapsObject> current1 = <TestMapsObject>{
        to2,
        to3Changed,
        to4
      };
      final Set<TestMapsObject> current2 = <TestMapsObject>{
        to2,
        to3Changed,
        to4
      };
      final Set<TestMapsObject> current3 = <TestMapsObject>{to2, to4};
      final TestMapsObjectUpdate updates1 =
          TestMapsObjectUpdate.from(previous, current1);
      final TestMapsObjectUpdate updates2 =
          TestMapsObjectUpdate.from(previous, current2);
      final TestMapsObjectUpdate updates3 =
          TestMapsObjectUpdate.from(previous, current3);
      expect(updates1, updates2);
      expect(updates1, isNot(updates3));
    });

    test('hashCode', () async {
      const TestMapsObject to1 =
          TestMapsObject(MapsObjectId<TestMapsObject>('id1'));
      const TestMapsObject to2 =
          TestMapsObject(MapsObjectId<TestMapsObject>('id2'));
      const TestMapsObject to3 =
          TestMapsObject(MapsObjectId<TestMapsObject>('id3'));
      const TestMapsObject to3Changed =
          TestMapsObject(MapsObjectId<TestMapsObject>('id3'), data: 2);
      const TestMapsObject to4 =
          TestMapsObject(MapsObjectId<TestMapsObject>('id4'));
      final Set<TestMapsObject> previous = <TestMapsObject>{to1, to2, to3};
      final Set<TestMapsObject> current = <TestMapsObject>{
        to2,
        to3Changed,
        to4
      };
      final TestMapsObjectUpdate updates =
          TestMapsObjectUpdate.from(previous, current);
      expect(
          updates.hashCode,
          Object.hash(
              Object.hashAll(updates.objectsToAdd),
              Object.hashAll(updates.objectIdsToRemove),
              Object.hashAll(updates.objectsToChange)));
    });

    test('toString', () async {
      const TestMapsObject to1 =
          TestMapsObject(MapsObjectId<TestMapsObject>('id1'));
      const TestMapsObject to2 =
          TestMapsObject(MapsObjectId<TestMapsObject>('id2'));
      const TestMapsObject to3 =
          TestMapsObject(MapsObjectId<TestMapsObject>('id3'));
      const TestMapsObject to3Changed =
          TestMapsObject(MapsObjectId<TestMapsObject>('id3'), data: 2);
      const TestMapsObject to4 =
          TestMapsObject(MapsObjectId<TestMapsObject>('id4'));
      final Set<TestMapsObject> previous = <TestMapsObject>{to1, to2, to3};
      final Set<TestMapsObject> current = <TestMapsObject>{
        to2,
        to3Changed,
        to4
      };
      final TestMapsObjectUpdate updates =
          TestMapsObjectUpdate.from(previous, current);
      expect(
          updates.toString(),
          'TestMapsObjectUpdate(add: ${updates.objectsToAdd}, '
          'remove: ${updates.objectIdsToRemove}, '
          'change: ${updates.objectsToChange})');
    });
  });
}
