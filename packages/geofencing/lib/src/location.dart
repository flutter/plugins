// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Internal.
Location locationFromList(List<double> l) => Location._fromList(l);

/// A simple representation of a geographic location.
class Location {
  final double latitude;
  final double longitude;

  const Location(this.latitude, this.longitude);

  Location._fromList(List<double> l)
      : assert(l.length == 2),
        latitude = l[0],
        longitude = l[1];

  @override
  String toString() => '($latitude, $longitude)';
}
