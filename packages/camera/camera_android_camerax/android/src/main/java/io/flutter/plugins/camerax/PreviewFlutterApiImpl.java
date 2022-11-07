// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.camera.core.Preview;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.PreviewFlutterApi;
import io.flutter.plugin.common.BinaryMessenger;


public class PreviewFlutterApiImpl extends PreviewFlutterApi {
    private final InstanceManager instanceManager;

    public PreviewFlutterApiImpl(
        BinaryMessenger binaryMessenger, InstanceManager instanceManager) {
            super(binaryMessenger);
            this.instanceManager = instanceManager;
    }
    
    void create(Preview preview, Long targetRotation, Reply<Void> reply) {
        create(instanceManager.addHostCreatedInstance(preview), targetRotation, reply);
    }
}
