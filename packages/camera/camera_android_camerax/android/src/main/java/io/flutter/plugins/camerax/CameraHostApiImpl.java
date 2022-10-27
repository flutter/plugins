// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import io.flutter.plugins.camerax.GeneratedCameraXLibrary.CameraHostApi;

public class CameraHostApiImpl {
    private final BinaryMessenger binaryMessenger;
    private final InstanceManager instanceManager;


    public CameraHostApiImpl(
        BinaryMessenger binaryMessenger, InstanceManager instanceManager) {
            this.binaryMessenger = binaryMessenger;
            this.instanceManager = instanceManager;
        }

    @Override
    public int getCameraControl(@NonNull Long identifier) {
        Camera camera = (Camera) instanceManager.getInstance(identifier);
        CameraControl cameraControl = camera.getCameraControl();

        // here
        final CameraInfoFlutterApiImpl cameraInfoFlutterApiImpl =
        new CameraInfoFlutterApiImpl(binaryMessenger, instanceManager);
        cameraInfoFlutterApiImpl.create(cameraInfo, result -> {});
        Long filteredCameraInfoId = instanceManager.getIdentifierForStrongReference(cameraInfo);
    }
}
