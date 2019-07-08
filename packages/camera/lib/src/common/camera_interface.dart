// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

enum CameraApi { android, iOS, supportAndroid }
enum LensDirection { front, back, external }

abstract class CameraDescription {
  LensDirection get direction;
  dynamic get id;
}

abstract class CameraConfigurator {
  int get previewTextureId;
  Future<void> start();
  Future<void> stop();
  Future<void> dispose();
  Future<void> addPreviewTexture();
}
