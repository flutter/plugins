// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter;

class CameraPosition {
  const CameraPosition({
    this.bearing = 0.0,
    @required this.target,
    this.tilt = 0.0,
    this.zoom = 0.0,
  })  : assert(bearing != null),
        assert(target != null),
        assert(tilt != null),
        assert(zoom != null);

  final double bearing;
  final LatLng target;
  final double tilt;
  final double zoom;

  dynamic _toJson() => <String, dynamic>{
        'bearing': bearing,
        'target': target._toJson(),
        'tilt': tilt,
        'zoom': zoom,
      };

  static CameraPosition _fromJson(dynamic json) {
    if (json == null) {
      return null;
    }
    return new CameraPosition(
      bearing: json['bearing'],
      target: LatLng._fromJson(json['target']),
      tilt: json['tilt'],
      zoom: json['zoom'],
    );
  }
}

class CameraUpdate {
  CameraUpdate._(this._json);

  final dynamic _json;

  static CameraUpdate newCameraPosition(CameraPosition cameraPosition) {
    return new CameraUpdate._(
      <dynamic>['newCameraPosition', cameraPosition._toJson()],
    );
  }

  static CameraUpdate newLatLng(LatLng latLng) {
    return new CameraUpdate._(<dynamic>['newLatLng', latLng._toJson()]);
  }

  static CameraUpdate newLatLngBounds(LatLngBounds bounds, double padding) {
    return new CameraUpdate._(<dynamic>[
      'newLatLngBounds',
      bounds._toJson(),
      padding * window.devicePixelRatio,
    ]);
  }

  static CameraUpdate newLatLngZoom(LatLng latLng, double zoom) {
    return new CameraUpdate._(
      <dynamic>['newLatLngZoom', latLng._toJson(), zoom],
    );
  }

  static CameraUpdate scrollBy(double xPixel, double yPixel) {
    return new CameraUpdate._(
      <dynamic>[
        'scrollBy',
        xPixel * window.devicePixelRatio,
        yPixel * window.devicePixelRatio,
      ],
    );
  }

  static CameraUpdate zoomBy(double amount, [Offset focus]) {
    if (focus == null) {
      return new CameraUpdate._(<dynamic>['zoomBy', amount]);
    } else {
      focus *= window.devicePixelRatio;
      return new CameraUpdate._(<dynamic>[
        'zoomBy',
        amount,
        <double>[focus.dx, focus.dy],
      ]);
    }
  }

  static CameraUpdate zoomIn() {
    return new CameraUpdate._(<dynamic>['zoomIn']);
  }

  static CameraUpdate zoomOut() {
    return new CameraUpdate._(<dynamic>['zoomOut']);
  }

  static CameraUpdate zoomTo(double zoom) {
    return new CameraUpdate._(<dynamic>['zoomTo', zoom]);
  }

  dynamic _toJson() => _json;
}
