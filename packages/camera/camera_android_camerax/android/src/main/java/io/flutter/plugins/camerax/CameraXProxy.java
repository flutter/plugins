// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.camera.core.CameraSelector;

public class CameraXProxy {
  public CameraSelector.Builder createCameraSelectorBuilder() {
    return new CameraSelector.Builder();
  }
}
