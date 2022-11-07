// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.PreviewHostApi;
import io.flutter.view.TextureRegistry;

public class PreviewHostApiImpl {
    private final BinaryMessenger binaryMessenger;
    private final InstanceManager instanceManager;

    @VisibleForTesting public CameraXProxy cameraXProxy = new CameraXProxy();

    public PreviewHostApiImpl(
        BinaryMessenger binaryMessenger, InstanceManager instanceManager) {
            this.binaryMessenger = binaryMessenger;
            this.instanceManager = instanceManager;
        }

    @Override
    public void create(@NonNull Long identifier, Long targetRotation) {
        CameraSelector.Builder previewBuilder = cameraXProxy.createPreviewBuilder();
        if (targetRotation != null) {
            previewBuilder.setTargetRotation(targetRotation);
        }
        Preview preview = previewBuilder.build();
        instanceManager.addDartCreatedInstance(preview, identifier);
    }

    @Override
    public int setSurfaceProvider(@NonNull Long identifier) {
        Preview preview = (Preview) instanceManager.getInstance(identifier);
        Preview.SurfaceProvider surfaceProvider = 
            new Preview.SurfaceProvider() {
                @Override
                void onSurface(SurfaceRequest request) {
                    TextureRegistry.SurfaceTextureEntry flutterSurfaceTexture =
                        textureRegistry.createSurfaceTexture();
                    SurfaceTexture surfaceTexture = flutterTexture.surfaceTexture();
                    Surface flutterSurface = new Surface(surfaceTexture);

                    // [?] Is this the correct Executor?
                    // [?] can use resultListener param to track when provided Surface is
                    //     no longer in use by the camera
                    request.provideSurface(flutterSurface, Executors.newSingleThreadExecutor(), (result) -> {});
                }
            };
        
        return flutterSurfaceTexture.id();
    }

    @Override
    void setTargetRotation(@NonNull Long identifier, @NonNull Long targetRotation) {
        Preview preview = (Preview) instanceManager.getInstance(identifier);
        preview.setTargetRotation(targetRotation);
    }
}
