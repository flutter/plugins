// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

public class CameraInfoHostApiImpl {
  public CameraInfoHostApiImpl(InstanceManager instanceManager) {
    //cameraInfo = new CameraInfo(); // you can only retrieve this though, not build it.
  }

  final InstanceManager instanceManager;

  @override
  CameraSelector getCameraSelector(long instance) {
    CameraInfo info = instanceManager.getInstance(instance);
    CameraSelector selector = info.getCameraSelector();

    // create an instance of CameraSelectorFlutterApiImpl
    // add selector to instance manager
    // call create with id of selctor

    return selector;
  }
}
