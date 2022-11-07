// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.core.Camera;
import androidx.camera.core.CameraControl;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.CameraHostApi;
import io.flutter.plugin.common.BinaryMessenger;


public class CameraHostApiImpl implements CameraHostApi {
    private final BinaryMessenger binaryMessenger;
    private final InstanceManager instanceManager;


    public CameraHostApiImpl(
        BinaryMessenger binaryMessenger, InstanceManager instanceManager) {
            this.binaryMessenger = binaryMessenger;
            this.instanceManager = instanceManager;
        }

    @Override
    public Long getCameraControl(@NonNull Long identifier) {
        Camera camera = (Camera) instanceManager.getInstance(identifier);
        CameraControl cameraControl = camera.getCameraControl();

        final CameraControlFlutterApiImpl cameraControlFlutterApiImpl =
            new CameraControlFlutterApiImpl(binaryMessenger, instanceManager);
        cameraControlFlutterApiImpl.create(cameraControl, result -> {});
        return instanceManager.getIdentifierForStrongReference(cameraControl);
    }
}
