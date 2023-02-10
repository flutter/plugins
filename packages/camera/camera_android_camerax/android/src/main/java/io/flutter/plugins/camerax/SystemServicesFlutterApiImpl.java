// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.SystemServicesFlutterApi;

public class SystemServicesFlutterApiImpl extends SystemServicesFlutterApi {
  public SystemServicesFlutterApiImpl(@NonNull BinaryMessenger binaryMessenger) {
    super(binaryMessenger);
  }

  public void sendDeviceOrientationChangedEvent(
      @NonNull String orientation, @NonNull Reply<Void> reply) {
    super.onDeviceOrientationChanged(orientation, reply);
  }

  public void sendCameraError(@NonNull String errorDescription, @NonNull Reply<Void> reply) {
    super.onCameraError(errorDescription, reply);
  }
}
