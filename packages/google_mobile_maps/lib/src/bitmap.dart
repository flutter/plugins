// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_mobile_maps;

class BitmapDescriptor {
  static const double hueRed = 0.0;
  static const double hueOrange = 30.0;
  static const double hueYellow = 60.0;
  static const double hueGreen = 120.0;
  static const double hueCyan = 180.0;
  static const double hueAzure = 210.0;
  static const double hueBlue = 240.0;
  static const double hueViolet = 270.0;
  static const double hueMagenta = 300.0;
  static const double hueRose = 330.0;

  const BitmapDescriptor._(this._json);

  static const BitmapDescriptor defaultMarker =
      const BitmapDescriptor._(<dynamic>['defaultMarker']);

  static BitmapDescriptor defaultMarkerWithHue(double hue) {
    assert(0.0 <= hue && hue < 360.0);
    return new BitmapDescriptor._(<dynamic>['defaultMarker', hue]);
  }

  static BitmapDescriptor fromAsset(String assetName, [String package]) {
    if (package == null) {
      return new BitmapDescriptor._(<dynamic>['fromAsset', assetName]);
    } else {
      return new BitmapDescriptor._(<dynamic>['fromAsset', assetName, package]);
    }
  }

  static BitmapDescriptor fromFile(String fileName) {
    return new BitmapDescriptor._(<dynamic>['fromFile', fileName]);
  }

  static BitmapDescriptor fromPath(String path) {
    return new BitmapDescriptor._(<dynamic>['fromPath', path]);
  }

  final dynamic _json;

  dynamic _toJson() => _json;
}
