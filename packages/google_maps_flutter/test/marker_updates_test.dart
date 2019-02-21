// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Set<Marker> _toSet({Marker m1, Marker m2, Marker m3}) {
  final Set<Marker> res = Set<Marker>.identity();
  if (m1 != null) {
    res.add(m1);
  }
  if (m2 != null) {
    res.add(m2);
  }
  if (m3 != null) {
    res.add(m3);
  }
  return res;
}

void main() {
  test("Adding a marker", () {
    final Marker m1 = Marker(markerId: MarkerId("marker_1"));
    final MarkerUpdates updates = MarkerUpdates.from(null, _toSet(m1: m1));
    expect(updates.markersToAdd.length, 1);

    final Marker update = updates.markersToAdd.first;
    expect(update, equals(m1));
    expect(updates.markerIdsToRemove.isEmpty, true);
    expect(updates.markersToChange.isEmpty, true);
  });

  test("Removing a marker", () {
    final Marker m1 = Marker(markerId: MarkerId("marker_1"));
    final MarkerUpdates updates = MarkerUpdates.from(_toSet(m1: m1), null);
    expect(updates.markerIdsToRemove.length, 1);
    expect(updates.markerIdsToRemove.first, equals(m1.markerId));
    expect(updates.markersToChange.isEmpty, true);
    expect(updates.markersToAdd.isEmpty, true);
  });

  test("Updating a marker", () {
    final Marker m1 = Marker(markerId: MarkerId("marker_1"));
    final Marker m2 = Marker(markerId: MarkerId("marker_1"), alpha: 0.5);
    final MarkerUpdates updates =
        MarkerUpdates.from(_toSet(m1: m1), _toSet(m2: m2));
    expect(updates.markersToChange.length, 1);

    final Marker update = updates.markersToChange.first;
    expect(update, equals(m2));
    expect(update.alpha, 0.5);
  });

  test("Updating a marker's InfoWindow", () {
    final Marker m1 = Marker(markerId: MarkerId("marker_1"));
    final Marker m2 = Marker(
      markerId: MarkerId("marker_1"),
      infoWindow: const InfoWindow(snippet: 'changed'),
    );
    final MarkerUpdates updates =
        MarkerUpdates.from(_toSet(m1: m1), _toSet(m2: m2));
    expect(updates.markersToChange.length, 1);

    final Marker update = updates.markersToChange.first;
    expect(update, equals(m2));
    expect(update.infoWindow.snippet, 'changed');
  });

  test('Multi Update', () {
    Marker m1 = Marker(markerId: MarkerId("marker_1"));
    Marker m2 = Marker(markerId: MarkerId("marker_2"));
    final Set<Marker> prev = _toSet(m1: m1, m2: m2);
    m1 = Marker(markerId: MarkerId("marker_1"), visible: false);
    m2 = Marker(markerId: MarkerId("marker_2"), draggable: true);
    final Set<Marker> cur = _toSet(m1: m1, m2: m2);
    final MarkerUpdates markerUpdates = MarkerUpdates.from(prev, cur);

    final MarkerUpdates expectedUpdate = MarkerUpdates.internal(
      // TODO(iskakaushik): Remove this when collection literals makes it to stable.
      // ignore: prefer_collection_literals
      markersToAdd: Set<Marker>(),
      // TODO(iskakaushik): Remove this when collection literals makes it to stable.
      // ignore: prefer_collection_literals
      markersToChange: Set<Marker>.from(<Marker>[m1, m2]),
      // TODO(iskakaushik): Remove this when collection literals makes it to stable.
      // ignore: prefer_collection_literals
      markerIdsToRemove: Set<MarkerId>(),
    );

    expect(markerUpdates, equals(expectedUpdate));
  });

  test('Add, remove and update.', () {
    Marker m2 = Marker(markerId: MarkerId("marker_2"));
    final Marker m3 = Marker(markerId: MarkerId("marker_3"));
    final Set<Marker> prev = _toSet(m2: m2, m3: m3);

    // m1 is added, m2 is updated, m3 is removed.
    final Marker m1 = Marker(markerId: MarkerId("marker_1"));
    m2 = Marker(markerId: MarkerId("marker_2"), draggable: true);
    final Set<Marker> cur = _toSet(m1: m1, m2: m2);

    final MarkerUpdates markerUpdates = MarkerUpdates.from(prev, cur);
    final MarkerUpdates expectedUpdate = MarkerUpdates.internal(
      // TODO(iskakaushik): Remove this when collection literals makes it to stable.
      // ignore: prefer_collection_literals
      markersToAdd: Set<Marker>.from(<Marker>[m1]),
      // TODO(iskakaushik): Remove this when collection literals makes it to stable.
      // ignore: prefer_collection_literals
      markersToChange: Set<Marker>.from(<Marker>[m2]),
      // TODO(iskakaushik): Remove this when collection literals makes it to stable.
      // ignore: prefer_collection_literals
      markerIdsToRemove: Set<MarkerId>.from(<MarkerId>[m3.markerId]),
    );

    expect(markerUpdates, equals(expectedUpdate));
  });
}
