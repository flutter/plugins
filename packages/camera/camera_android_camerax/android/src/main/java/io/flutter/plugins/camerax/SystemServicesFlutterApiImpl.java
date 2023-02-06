// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.SystemServicesFlutterApi;

public class SystemServicesFlutterApiImpl extends SystemServicesFlutterApi {
  public SystemServicesFlutterApiImpl(
      BinaryMessenger binaryMessenger, InstanceManager instanceManager) {
    super(binaryMessenger);
    this.instanceManager = instanceManager;
  }

  private final InstanceManager instanceManager;

  public void onDeviceOrientationChanged(String orientation, Reply<Void> reply) {
    super.onDeviceOrientationChanged(orientation, reply);
  }
}
