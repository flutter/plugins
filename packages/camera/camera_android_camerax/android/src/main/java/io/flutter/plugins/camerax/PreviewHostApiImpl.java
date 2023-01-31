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

  @VisibleForTesting public CameraXProxy cameraXProxy = new CameraXProxy();

  @VisibleForTesting public TextureRegistry.SurfaceTextureEntry flutterSurfaceTexture;

  public PreviewHostApiImpl(
      BinaryMessenger binaryMessenger,
      InstanceManager instanceManager,
      TextureRegistry textureRegistry) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
    this.textureRegistry = textureRegistry;
  }

  /** Creates a {@link Preview} with the target rotation and resolution if specified. */
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

  /**
   * Sets the {@link Preview.SurfaceProvider} that will be used to provide a {@code Surface} backed
   * by a Flutter {@link TextureRegistry.SurfaceTextureEntry} used to build the {@link Preview}.
   */
  @Override
  public Long setSurfaceProvider(@NonNull Long identifier) {
    Preview preview = (Preview) instanceManager.getInstance(identifier);
    flutterSurfaceTexture = textureRegistry.createSurfaceTexture();
    SurfaceTexture surfaceTexture = flutterSurfaceTexture.surfaceTexture();
    Preview.SurfaceProvider surfaceProvider =
        new Preview.SurfaceProvider() {
          @Override
          public void onSurfaceRequested(SurfaceRequest request) {
            surfaceTexture.setDefaultBufferSize(
                request.getResolution().getWidth(), request.getResolution().getHeight());
            Surface flutterSurface = cameraXProxy.createSurface(surfaceTexture);
            request.provideSurface(
                flutterSurface,
                Executors.newSingleThreadExecutor(),
                (result) -> {
                  SystemServicesFlutterApiImpl systemServicesFlutterApi =
                      cameraXProxy.createSystemServicesFlutterApi(binaryMessenger);
                  int resultCode = result.getResultCode();
                  switch (resultCode) {
                    case SurfaceRequest.Result.RESULT_SURFACE_USED_SUCCESSFULLY:
                      flutterSurface.release();
                      break;
                    case SurfaceRequest.Result.RESULT_REQUEST_CANCELLED:
                    case SurfaceRequest.Result.RESULT_INVALID_SURFACE:
                    case SurfaceRequest.Result.RESULT_WILL_NOT_PROVIDE_SURFACE:
                      flutterSurface.release();
                    case SurfaceRequest.Result.RESULT_SURFACE_ALREADY_PROVIDED:
                    default:
                      systemServicesFlutterApi.sendCameraError(
                          getProvideSurfaceErrorDescription(resultCode), reply -> {});
                      break;
                  }
                });
          };
        };
    preview.setSurfaceProvider(surfaceProvider);
    return flutterSurfaceTexture.id();
  }

  /**
   * Returns an error description for each {@link SurfaceRequest.Result} that represents an error
   * with providing a surface.
   */
  private String getProvideSurfaceErrorDescription(int resultCode) {
    switch (resultCode) {
      case SurfaceRequest.Result.RESULT_REQUEST_CANCELLED:
        return "Provided surface was never attached to the camera becausethe SurfaceRequest was cancelled by the camera.";
      case SurfaceRequest.Result.RESULT_INVALID_SURFACE:
        return "Provided surface could not be used by the camera.";
      case SurfaceRequest.Result.RESULT_SURFACE_ALREADY_PROVIDED:
        return "Provided surface was never attached to the camera because the SurfaceRequest was cancelled by the camera.";
      case SurfaceRequest.Result.RESULT_WILL_NOT_PROVIDE_SURFACE:
        return "Surface was not attached to the camera because the SurfaceRequest was marked as 'will not provide surface'.";
      default:
        return "There was an error with providing a surface for the camera preview.";
    }
  }

  /**
   * Releases the Flutter {@link TextureRegistry.SurfaceTextureEntry} if used to provide a surface
   * for a {@link Preview}.
   */
  @Override
  public void releaseFlutterSurfaceTexture() {
    if (flutterSurfaceTexture != null) {
      flutterSurfaceTexture.release();
    }
  }

  /** Returns the resolution information for the specified {@link Preview}. */
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
