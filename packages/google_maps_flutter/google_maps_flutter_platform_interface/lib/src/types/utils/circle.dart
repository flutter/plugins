// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../types.dart';
import 'maps_object.dart';

/// Converts an [Iterable] of Circles in a Map of CircleId -> Circle.
Map<CircleId, Circle> keyByCircleId(Iterable<Circle> circles) {
  return keyByMapsObjectId<Circle>(circles).cast<CircleId, Circle>();
}

/// Converts a Set of Circles into something serializable in JSON.
Object serializeCircleSet(Set<Circle> circles) {
  return serializeMapsObjectSet(circles);
}
