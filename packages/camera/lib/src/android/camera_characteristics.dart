// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of android_camera;

enum CameraCharacteristicKey { lensFacing, sensorOrientation }
enum LensFacing { front, back, external }

class CameraCharacteristics implements CameraDescription {
  CameraCharacteristics._({
    @required this.id,
    @required this.lensFacing,
    @required this.sensorOrientation,
  })  : assert(id != null),
        assert(lensFacing != null),
        assert(sensorOrientation != null);

  factory CameraCharacteristics._fromMap(Map<String, dynamic> map) {
    return CameraCharacteristics._(
      id: map['id'],
      sensorOrientation: map['sensorOrientation'],
      lensFacing: LensFacing.values.firstWhere(
        (LensFacing facing) => facing.toString() == map['lensFacing'],
      ),
    );
  }

  final String id;
  final LensFacing lensFacing;
  final int sensorOrientation;

  @override
  LensDirection get direction {
    switch (lensFacing) {
      case LensFacing.front:
        return LensDirection.front;
      case LensFacing.back:
        return LensDirection.back;
      case LensFacing.external:
        return LensDirection.external;
    }

    return null;
  }
}
