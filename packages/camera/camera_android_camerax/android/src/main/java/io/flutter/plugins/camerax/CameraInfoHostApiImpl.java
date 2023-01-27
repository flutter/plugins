// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.core.CameraInfo;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.CameraInfoHostApi;
import java.util.Objects;

public class CameraInfoHostApiImpl implements CameraInfoHostApi {
  private final InstanceManager instanceManager;

  public CameraInfoHostApiImpl(InstanceManager instanceManager) {
    this.instanceManager = instanceManager;
  }

  @Override
  public Long getSensorRotationDegrees(@NonNull Long identifier) {
    CameraInfo cameraInfo =
        (CameraInfo) Objects.requireNonNull(instanceManager.getInstance(identifier));
    return Long.valueOf(cameraInfo.getSensorRotationDegrees());
  }
}
