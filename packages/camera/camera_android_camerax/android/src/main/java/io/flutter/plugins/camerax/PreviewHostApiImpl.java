// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.graphics.SurfaceTexture;
import android.view.Surface;
import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import androidx.camera.core.CameraSelector;
import androidx.camera.core.Preview;
import androidx.camera.core.SurfaceRequest;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.PreviewHostApi;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.view.TextureRegistry;
import java.util.concurrent.Executors;

public class PreviewHostApiImpl implements PreviewHostApi {
    private final BinaryMessenger binaryMessenger;
    private final InstanceManager instanceManager;
    private final TextureRegistry textureRegistry;

    @VisibleForTesting public CameraXProxy cameraXProxy = new CameraXProxy();

    public PreviewHostApiImpl(
        BinaryMessenger binaryMessenger, InstanceManager instanceManager, TextureRegistry textureRegistry) {
            this.binaryMessenger = binaryMessenger;
            this.instanceManager = instanceManager;
            this.textureRegistry = textureRegistry;
        }

    @Override
    public void create(@NonNull Long identifier, @NonNull Long targetRotation) {
        Preview.Builder previewBuilder = cameraXProxy.createPreviewBuilder();
        if (targetRotation != null) {
            previewBuilder.setTargetRotation(targetRotation.intValue());
        }
        Preview preview = previewBuilder.build();
        instanceManager.addDartCreatedInstance(preview, identifier);
    }

    @Override
    public Long setSurfaceProvider(@NonNull Long identifier) {
        Preview preview = (Preview) instanceManager.getInstance(identifier);
        TextureRegistry.SurfaceTextureEntry flutterSurfaceTexture =
            textureRegistry.createSurfaceTexture(); // get this from the plugin
        SurfaceTexture surfaceTexture = flutterSurfaceTexture.surfaceTexture();
        Surface flutterSurface = new Surface(surfaceTexture);
        Preview.SurfaceProvider surfaceProvider = 
            new Preview.SurfaceProvider() {
                @Override
                public void onSurfaceRequested(SurfaceRequest request) {
                    // [?] Is this the correct Executor?
                    // [?] can use resultListener param to track when provided Surface is
                    //     no longer in use by the camera
                    request.provideSurface(flutterSurface, Executors.newSingleThreadExecutor(), (result) -> {});
                }
            };
        
        return flutterSurfaceTexture.id();
    }

    @Override
    public void setTargetRotation(@NonNull Long identifier, @NonNull Long targetRotation) {
        Preview preview = (Preview) instanceManager.getInstance(identifier);
        preview.setTargetRotation(targetRotation.intValue());
    }
}
