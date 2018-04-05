// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_mobile_maps;

class MarkerOptions {
  final LatLng position;

  const MarkerOptions({@required this.position}) : assert(position != null);

  dynamic _toJson() => <String, dynamic>{
        'position': position._toJson(),
      };
}
