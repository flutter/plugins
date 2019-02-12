// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter;

class MarkerV2 {
  MarkerV2({
    @required this.markerId,
    @required this.position,
    this.alpha,
    this.onDrag,
  });

  final String markerId;
  final double alpha;
  final LatLng position;
  final ValueChanged<LatLng> onDrag;

  Map<String, dynamic> _toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};

    void addIfPresent(String fieldName, dynamic value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('markerId', markerId);
    addIfPresent('alpha', alpha);
    addIfPresent('position', position?._toJson());
    return json;
  }
}
