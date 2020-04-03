// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../types.dart';

/// Converts an [Iterable] of Circles in a Map of CircleId -> Circle.
Map<CircleId, Circle> keyByCircleId(Iterable<Circle> circles) {
  if (circles == null) {
    return <CircleId, Circle>{};
  }
  return Map<CircleId, Circle>.fromEntries(circles.map((Circle circle) =>
      MapEntry<CircleId, Circle>(circle.circleId, circle.clone())));
}

/// Converts a Set of Circles into something serializable in JSON.
List<Map<String, dynamic>> serializeCircleSet(Set<Circle> circles) {
  if (circles == null) {
    return null;
  }
  return circles.map<Map<String, dynamic>>((Circle p) => p.toJson()).toList();
}
