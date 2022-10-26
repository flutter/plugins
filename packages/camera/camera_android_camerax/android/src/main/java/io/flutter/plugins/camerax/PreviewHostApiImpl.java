// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import io.flutter.plugins.camerax.GeneratedCameraXLibrary.PreviewHostApi;

public class PreviewHostApiImpl {
    private final BinaryMessenger binaryMessenger;
    private final InstanceManager instanceManager;

    public PreviewHostApiImpl(
        BinaryMessenger binaryMessenger, InstanceManager instanceManager) {
            this.binaryMessenger = binaryMessenger;
            this.instanceManager = instanceManager;
        }

    @Override
    public void create(@NonNull Long identifier, Long targetRotation) {
        // implementation details
    }

    @Override
    public int setSurfaceProvider(@NonNull Long identifier) {
        // implementation details
    }

    @Override
    void setTargetRotation(@NonNull Long identifier, @NonNull Long targetRotation) {
        // implementation details
    }
}
