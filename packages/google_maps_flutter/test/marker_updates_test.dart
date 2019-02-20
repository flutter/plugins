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
    expect(updates.markerUpdates.length, 1);

    final MarkerUpdate update = updates.markerUpdates.first;
    expect(
      update,
      equals(MarkerUpdate.internal(
        updateEventType: MarkerUpdateEventType.add,
        markerId: m1.markerId,
        newMarker: m1,
        changes: m1,
      )),
    );
  });

  test("Removing a marker", () {
    final Marker m1 = Marker(markerId: MarkerId("marker_1"));
    final MarkerUpdates updates = MarkerUpdates.from(_toSet(m1: m1), null);
    expect(updates.markerUpdates.length, 1);

    final MarkerUpdate update = updates.markerUpdates.first;
    expect(
      update,
      equals(MarkerUpdate.internal(
        updateEventType: MarkerUpdateEventType.remove,
        markerId: m1.markerId,
      )),
    );
  });

  test("Updating a marker", () {
    final Marker m1 = Marker(markerId: MarkerId("marker_1"));
    final Marker m2 = Marker(markerId: MarkerId("marker_1"), alpha: 0.5);
    final MarkerUpdates updates =
        MarkerUpdates.from(_toSet(m1: m1), _toSet(m2: m2));
    expect(updates.markerUpdates.length, 1);

    final MarkerUpdate update = updates.markerUpdates.first;
    expect(
      update,
      equals(MarkerUpdate.internal(
          updateEventType: MarkerUpdateEventType.update,
          markerId: m1.markerId,
          newMarker: m2,
          changes: m2)),
    );
    expect(update.newMarker.alpha, 0.5);
  });

  test("Updating a marker's InfoWindow", () {
    final Marker m1 = Marker(markerId: MarkerId("marker_1"));
    final Marker m2 = Marker(
      markerId: MarkerId("marker_1"),
      infoWindow: const InfoWindow(snippet: 'changed'),
    );
    final MarkerUpdates updates =
        MarkerUpdates.from(_toSet(m1: m1), _toSet(m2: m2));
    expect(updates.markerUpdates.length, 1);

    final MarkerUpdate update = updates.markerUpdates.first;
    expect(
      update,
      equals(MarkerUpdate.internal(
          updateEventType: MarkerUpdateEventType.update,
          markerId: m1.markerId,
          newMarker: m2,
          changes: m2)),
    );
    expect(update.newMarker.infoWindow.snippet, 'changed');
  });

  test('Multi Update', () {
    Marker m1 = Marker(markerId: MarkerId("marker_1"));
    Marker m2 = Marker(markerId: MarkerId("marker_2"));
    final Set<Marker> prev = _toSet(m1: m1, m2: m2);
    m1 = Marker(markerId: MarkerId("marker_1"), visible: false);
    m2 = Marker(markerId: MarkerId("marker_2"), draggable: true);
    final Set<Marker> cur = _toSet(m1: m1, m2: m2);
    final MarkerUpdates updates = MarkerUpdates.from(prev, cur);
    final MarkerUpdates expectedUpdate = MarkerUpdates.internal(
      markerUpdates: Set<MarkerUpdate>.from(
        <MarkerUpdate>[
          MarkerUpdate.internal(
            updateEventType: MarkerUpdateEventType.update,
            markerId: m1.markerId,
            newMarker: m1,
            changes: m1,
          ),
          MarkerUpdate.internal(
            updateEventType: MarkerUpdateEventType.update,
            markerId: m2.markerId,
            newMarker: m2,
            changes: m2,
          ),
        ],
      ),
    );

    expect(
        _checkUnorderedEquality(
          updates.markerUpdates,
          expectedUpdate.markerUpdates,
        ),
        true);
  });

  test('Add, remove and update.', () {
    Marker m2 = Marker(markerId: MarkerId("marker_2"));
    final Marker m3 = Marker(markerId: MarkerId("marker_3"));
    final Set<Marker> prev = _toSet(m2: m2, m3: m3);

    // m1 is added, m2 is updated, m3 is removed.
    final Marker m1 = Marker(markerId: MarkerId("marker_1"));
    m2 = Marker(markerId: MarkerId("marker_2"), draggable: true);
    final Set<Marker> cur = _toSet(m1: m1, m2: m2);

    final MarkerUpdates updates = MarkerUpdates.from(prev, cur);
    final MarkerUpdates expectedUpdate = MarkerUpdates.internal(
      markerUpdates: Set<MarkerUpdate>.from(
        <MarkerUpdate>[
          MarkerUpdate.internal(
            updateEventType: MarkerUpdateEventType.add,
            markerId: m1.markerId,
            newMarker: m1,
            changes: m1,
          ),
          MarkerUpdate.internal(
            updateEventType: MarkerUpdateEventType.update,
            markerId: m2.markerId,
            newMarker: m2,
            changes: m2,
          ),
          MarkerUpdate.internal(
            updateEventType: MarkerUpdateEventType.remove,
            markerId: m3.markerId,
          ),
        ],
      ),
    );

    expect(
        _checkUnorderedEquality(
          updates.markerUpdates,
          expectedUpdate.markerUpdates,
        ),
        true);
  });
}

bool _checkUnorderedEquality(
  Set<MarkerUpdate> updates1,
  Set<MarkerUpdate> updates2,
) {
  if (updates1 == null || updates2 == null) {
    return false;
  }
  if (updates1.length != updates2.length) {
    return false;
  }
  for (MarkerUpdate update1 in updates1) {
    bool found = false;
    for (MarkerUpdate update2 in updates2) {
      if (update1 == update2) {
        found = true;
        break;
      }
    }
    if (!found) {
      return false;
    }
  }
  return true;
}
