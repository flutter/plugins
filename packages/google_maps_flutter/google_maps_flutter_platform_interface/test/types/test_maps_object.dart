// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter_platform_interface/src/types/maps_object.dart';
import 'package:google_maps_flutter_platform_interface/src/types/maps_object_updates.dart';

/// A trivial TestMapsObject implementation for testing updates with.
@immutable
class TestMapsObject implements MapsObject<TestMapsObject> {
  const TestMapsObject(this.mapsId, {this.data = 1});

  @override
  final MapsObjectId<TestMapsObject> mapsId;

  final int data;

  @override
  TestMapsObject clone() {
    return TestMapsObject(mapsId, data: data);
  }

  @override
  Object toJson() {
    return <String, Object>{'id': mapsId.value};
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is TestMapsObject &&
        mapsId == other.mapsId &&
        data == other.data;
  }

  @override
  int get hashCode => Object.hash(mapsId, data);
}

class TestMapsObjectUpdate extends MapsObjectUpdates<TestMapsObject> {
  TestMapsObjectUpdate.from(
      Set<TestMapsObject> previous, Set<TestMapsObject> current)
      : super.from(previous, current, objectName: 'testObject');
}
