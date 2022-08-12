// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

public class CameraInfoHostApiImpl extends CameraHostApi {
  final InstanceManager instanceManager;

  public CameraInfoHostApiImpl(
    InstanceManager instanceManager) {
    this.instanceManager = instanceManager;
  }

  @override
  Long getSensorOrientationDegrees(@NonNull Long instanceId) {
    CameraInfo cameraInfo =
      (CameraInfo) instanceManager.getInstance(instanceId); // may return null?
    return cameraInfo.getSensorOrientationDegrees();
  }  
}
