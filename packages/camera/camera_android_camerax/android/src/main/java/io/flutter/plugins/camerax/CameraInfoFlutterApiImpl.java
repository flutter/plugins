// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.camera.core.CameraInfo;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.CameraInfoFlutterApi;

public class CameraInfoFlutterApiImpl extends CameraInfoFlutterApi {
  private final InstanceManager instanceManager;

  public CameraInfoFlutterApiImpl(
      BinaryMessenger binaryMessenger, InstanceManager instanceManager) {
    super(binaryMessenger);
    this.instanceManager = instanceManager;
  }

  void create(CameraInfo cameraInfo, Reply<Void> reply) {
    instanceManager.addHostCreatedInstance(cameraInfo);
    create(instanceManager.getIdentifierForStrongReference(cameraInfo), reply);
  }
}
