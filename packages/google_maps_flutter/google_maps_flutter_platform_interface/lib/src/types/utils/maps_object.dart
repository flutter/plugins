// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../maps_object.dart';

/// Converts an [Iterable] of [MapsObject]s in a Map of [MapObjectId] -> [MapObject].
Map<MapsObjectId<T>, T> keyByMapsObjectId<T extends MapsObject>(
    Iterable<T> objects) {
  return Map<MapsObjectId<T>, T>.fromEntries(objects.map((T object) =>
      MapEntry<MapsObjectId<T>, T>(
          object.mapsId as MapsObjectId<T>, object.clone())));
}

/// Converts a Set of [MapsObject]s into something serializable in JSON.
Object serializeMapsObjectSet(Set<MapsObject> mapsObjects) {
  return mapsObjects.map<Object>((MapsObject p) => p.toJson()).toList();
}
