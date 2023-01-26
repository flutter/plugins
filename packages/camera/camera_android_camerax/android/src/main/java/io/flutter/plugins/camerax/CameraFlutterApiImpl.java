// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.camera.core.Camera;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.CameraFlutterApi;

public class CameraFlutterApiImpl extends CameraFlutterApi {
  private final InstanceManager instanceManager;

  public CameraFlutterApiImpl(BinaryMessenger binaryMessenger, InstanceManager instanceManager) {
    super(binaryMessenger);
    this.instanceManager = instanceManager;
  }

  void create(Camera camera, Reply<Void> reply) {
    create(instanceManager.addHostCreatedInstance(camera), reply);
  }
}
