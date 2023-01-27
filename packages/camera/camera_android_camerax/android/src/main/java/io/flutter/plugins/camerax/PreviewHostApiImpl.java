// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.graphics.SurfaceTexture;
import android.util.Size;
import android.view.Surface;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import androidx.camera.core.Preview;
import androidx.camera.core.SurfaceRequest;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.PreviewHostApi;
import io.flutter.view.TextureRegistry;
import java.util.concurrent.Executors;

public class PreviewHostApiImpl implements PreviewHostApi {
  private final BinaryMessenger binaryMessenger;
  private final InstanceManager instanceManager;
  private final TextureRegistry textureRegistry;

  private final String RESOLUTION_WIDTH_KEY = "width";
  private final String RESOLUTION_HEIGHT_KEY = "height";

  @VisibleForTesting public CameraXProxy cameraXProxy = new CameraXProxy();

  public PreviewHostApiImpl(
      BinaryMessenger binaryMessenger,
      InstanceManager instanceManager,
      TextureRegistry textureRegistry) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
    this.textureRegistry = textureRegistry;
  }

  @Override
  public void create(
      @NonNull Long identifier,
      @Nullable Long rotation,
      @Nullable GeneratedCameraXLibrary.ResolutionInfo targetResolution) {
    Preview.Builder previewBuilder = cameraXProxy.createPreviewBuilder();
    if (rotation != null) {
      previewBuilder.setTargetRotation(rotation.intValue());
    }
    if (targetResolution != null) {
      previewBuilder.setTargetResolution(
          new Size(
              targetResolution.getWidth().intValue(), targetResolution.getHeight().intValue()));
    }
    Preview preview = previewBuilder.build();
    instanceManager.addDartCreatedInstance(preview, identifier);
  }

  @Override
  public Long setSurfaceProvider(@NonNull Long identifier) {
    Preview preview = (Preview) instanceManager.getInstance(identifier);
    TextureRegistry.SurfaceTextureEntry flutterSurfaceTexture =
        textureRegistry.createSurfaceTexture();
    SurfaceTexture surfaceTexture = flutterSurfaceTexture.surfaceTexture();
    Preview.SurfaceProvider surfaceProvider =
        new Preview.SurfaceProvider() {
          @Override
          public void onSurfaceRequested(SurfaceRequest request) {
            surfaceTexture.setDefaultBufferSize(
                request.getResolution().getWidth(), request.getResolution().getHeight());
            Surface flutterSurface = cameraXProxy.createSurface(surfaceTexture);
            request.provideSurface(
                flutterSurface, Executors.newSingleThreadExecutor(), (result) -> {});
          };
        };
    preview.setSurfaceProvider(surfaceProvider);
    return flutterSurfaceTexture.id();
  }

  @Override
  public GeneratedCameraXLibrary.ResolutionInfo getResolutionInfo(@NonNull Long identifier) {
    Preview preview = (Preview) instanceManager.getInstance(identifier);
    Size resolution = preview.getResolutionInfo().getResolution();

    GeneratedCameraXLibrary.ResolutionInfo.Builder resolutionInfo =
        new GeneratedCameraXLibrary.ResolutionInfo.Builder()
            .setWidth(Long.valueOf(resolution.getWidth()))
            .setHeight(Long.valueOf(resolution.getHeight()));
    return resolutionInfo.build();
  }
}
