// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.core.CameraControl;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.CameraControlHostApi;
import io.flutter.plugin.common.BinaryMessenger;

public class CameraControlHostApiImpl implements CameraControlHostApi {
    private final BinaryMessenger binaryMessenger;
    private final InstanceManager instanceManager;


    public CameraControlHostApiImpl(
        BinaryMessenger binaryMessenger, InstanceManager instanceManager) {
            this.binaryMessenger = binaryMessenger;
            this.instanceManager = instanceManager;
        }

    @Override
    public void setZoomRatio(@NonNull Long identifier, @NonNull Long ratio) {
        CameraControl cameraControl = (CameraControl) instanceManager.getInstance(identifier);
        cameraControl.setZoomRatio(ratio);
    }
}
