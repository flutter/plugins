// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../maps_object.dart';

/// Converts an [Iterable] of [MapsObject]s in a Map of [MapObjectId] -> [MapObject].
Map<MapsObjectId<T>, T> keyByMapsObjectId<T extends MapsObject>(Iterable<T>? objects) {
  if (objects == null) {
    return <MapsObjectId<T>, T>{};
  }
  return Map<MapsObjectId<T>, T>.fromEntries(objects.map((T object) =>
      MapEntry<MapsObjectId<T>, T>(object.mapsId as MapsObjectId<T>, object.clone())));
}

/// Converts a Set of [MapsObject]s into something serializable in JSON.
List<Map<String, dynamic>>? serializeMapsObjectSet(
    Set<MapsObject>? mapsObjects) {
  if (mapsObjects == null) {
    return null;
  }
  return mapsObjects
      .map<Map<String, dynamic>>((MapsObject p) => p.toJson())
      .toList();
}
