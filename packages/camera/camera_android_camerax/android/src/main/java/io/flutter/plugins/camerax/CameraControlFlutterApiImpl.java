// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.camera.core.CameraControl;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.CameraControlFlutterApi;

public class CameraControlFlutterApiImpl extends CameraFlutterApi {
  private final InstanceManager instanceManager;

  public CameraControlFlutterApiImpl(
      BinaryMessenger binaryMessenger, InstanceManager instanceManager) {
    super(binaryMessenger);
    this.instanceManager = instanceManager;
  }

  void create(CameraControl cameraControl, Reply<Void> reply) {
    create(instanceManager.addHostCreatedInstance(cameraControl), reply);
  }
}
