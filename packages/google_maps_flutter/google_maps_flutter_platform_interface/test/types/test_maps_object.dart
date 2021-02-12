// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' show hashValues;
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter_platform_interface/src/types/maps_object_updates.dart';
import 'package:google_maps_flutter_platform_interface/src/types/maps_object.dart';

/// A trivial TestMapsObject implementation for testing updates with.
class TestMapsObject implements MapsObject {
  TestMapsObject(this.mapsId, {this.data = 1});

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
  int get hashCode => hashValues(mapsId, data);
}

class TestMapsObjectUpdate extends MapsObjectUpdates<TestMapsObject> {
  TestMapsObjectUpdate.from(
      Set<TestMapsObject> previous, Set<TestMapsObject> current)
      : super.from(previous, current, objectName: 'testObject');
}
