// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.camera.core.CameraSelector;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.CameraSelectorFlutterApi;

public class CameraSelectorFlutterApiImpl extends CameraSelectorFlutterApi {
  private final InstanceManager instanceManager;

  public CameraSelectorFlutterApiImpl(
      BinaryMessenger binaryMessenger, InstanceManager instanceManager) {
    super(binaryMessenger);
    this.instanceManager = instanceManager;
  }

  void create(CameraSelector cameraSelector, Long lensFacing, Reply<Void> reply) {
    create(instanceManager.addHostCreatedInstance(cameraSelector), lensFacing, reply);
  }
}
