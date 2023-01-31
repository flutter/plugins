// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.SystemServicesFlutterApi;

public class SystemServicesFlutterApiImpl extends SystemServicesFlutterApi {
  public SystemServicesFlutterApiImpl(BinaryMessenger binaryMessenger) {
    super(binaryMessenger);
  }

  public void sendDeviceOrientationChanged(String orientation, Reply<Void> reply) {
    super.onDeviceOrientationChanged(orientation, reply);
  }

  public void sendCameraError(String errorDescription, Reply<Void> reply) {
    super.onCameraError(errorDescription, reply);
  }
}
