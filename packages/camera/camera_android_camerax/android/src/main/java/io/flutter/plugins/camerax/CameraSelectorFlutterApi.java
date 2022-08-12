// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

public class CameraSelectorFlutterApiImpl extends CameraSelectorFlutterApi {
  private final InstanceManager instanceManager;

  public CameraSelectorFlutterApiImpl(
    BinaryMessenger binaryMessenger,
    InstanceManager instanceManager) {
    super(binaryMessenger);
    this.instanceManager = instanceManager;
  }

  void create(CameraSelector cameraSelector, Reply<Void> reply) {
    create(instanceManager.getIdentifierForStrongReference(cameraSelector), reply);
  }
}
