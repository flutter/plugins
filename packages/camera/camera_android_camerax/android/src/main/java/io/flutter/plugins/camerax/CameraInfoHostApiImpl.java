// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.core.CameraInfo;
import androidx.camera.core.CameraSelector;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.CameraInfoHostApi;

public class CameraInfoHostApiImpl implements CameraInfoHostApi {
  private final BinaryMessenger binaryMessenger;
  private final InstanceManager instanceManager;

  public CameraInfoHostApiImpl(BinaryMessenger binaryMessenger, InstanceManager instanceManager) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
  }

  @Override
  public Long getSensorRotationDegrees(@NonNull Long identifier) {
    CameraInfo cameraInfo = (CameraInfo) instanceManager.getInstance(identifier);
    return Long.valueOf(cameraInfo.getSensorRotationDegrees());
  }

  @Override
  public Long getCameraSelector(@NonNull Long identifier) {
    CameraInfo cameraInfo = (CameraInfo) instanceManager.getInstance(identifier);
    CameraSelector cameraSelector = cameraInfo.getCameraSelector();

    final CameraSelectorFlutterApiImpl cameraSelectorFlutterApiImpl =
        new CameraSelectorFlutterApiImpl(binaryMessenger, instanceManager);
    cameraSelectorFlutterApiImpl.create(
        cameraSelector, Long.valueOf(cameraSelector.getLensFacing()), result -> {});

    return instanceManager.getIdentifierForStrongReference(cameraSelector);
  }
}
