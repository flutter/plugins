// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.graphics.SurfaceTexture;
import android.util.Log;
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
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.Executors;

import java.util.concurrent.Executor;
import android.os.Handler;
import android.os.Looper;

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
      @Nullable Map<String, Long> targetResolution) {
    Preview.Builder previewBuilder = cameraXProxy.createPreviewBuilder();
    if (rotation != null) {
      previewBuilder.setTargetRotation(rotation.intValue());
    }
    if (targetResolution != null) {
      previewBuilder.setTargetResolution(
          new Size(
              ((Number) targetResolution.get(RESOLUTION_WIDTH_KEY)).intValue(),
              ((Number) targetResolution.get(RESOLUTION_HEIGHT_KEY)).intValue()));
    }
    Preview preview = previewBuilder.build();
    Log.e("FLUTTER", "CAMILLE preview built with identifier " + identifier);
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
            Surface flutterSurface = new Surface(surfaceTexture);
            request.provideSurface(
                flutterSurface, new UiThreadExecutor(),
                (result) -> {
                  int resultCode = result.getResultCode();
                  switch (resultCode) {
                    case SurfaceRequest.Result.RESULT_SURFACE_USED_SUCCESSFULLY:
                      flutterSurface.release();
                      break;
                    case SurfaceRequest.Result.RESULT_REQUEST_CANCELLED:
                    case SurfaceRequest.Result.RESULT_INVALID_SURFACE:
                    case SurfaceRequest.Result.RESULT_WILL_NOT_PROVIDE_SURFACE:
                    case SurfaceRequest.Result.RESULT_SURFACE_ALREADY_PROVIDED:
                      flutterSurface.release();
                    default:
                      break;
                  }
                  });
          };
        };
    preview.setSurfaceProvider(surfaceProvider);
    return flutterSurfaceTexture.id();
  }

  private static class UiThreadExecutor implements Executor {
    final Handler handler = new Handler(Looper.getMainLooper());

    @Override
    public void execute(Runnable command) {
      handler.post(command);
    }
  }

  @Override
  public void setTargetRotation(@NonNull Long identifier, @NonNull Long targetRotation) {
    Preview preview = (Preview) instanceManager.getInstance(identifier);
    preview.setTargetRotation(targetRotation.intValue());
  }

  @Override
  public Map<String, Long> getResolutionInfo(@NonNull Long identifier) {
    Preview preview = (Preview) instanceManager.getInstance(identifier);
    Size resolution = preview.getResolutionInfo().getResolution();

    // TODO(camsim99): Establish constants for keys.
    // TODO(camsim99): Determine why the values are swapped.
    Map<String, Long> doubleBraceMap =
        new HashMap<String, Long>() {
          {
            put("height", Long.valueOf(resolution.getWidth()));
            put("width", Long.valueOf(resolution.getHeight()));
          }
        };
    return doubleBraceMap;
  }
}
