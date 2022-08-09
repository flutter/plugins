// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

public class ProcessCameraProviderFlutterApiImpl extends ProcessCameraProviderFlutterApi {
    public ProcessCameraProviderFlutterApiImpl(BinaryMessenger binaryMessenger, InstanceManager instanceManager) {
        super(binaryMessenger);
        this.instanceManager = instanceManager;
      }

    private final InstanceManager instanceManager;

    void create(ProcessCameraProvider processCameraProvider, Reply<Void> reply) {
        create(instanceManager.getIdentifierForStrongReference(processCameraProvider), reply);
    }
}