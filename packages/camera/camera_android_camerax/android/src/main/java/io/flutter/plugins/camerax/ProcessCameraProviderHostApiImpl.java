// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.camera.core.CameraInfo;
import androidx.camera.lifecycle.ProcessCameraProvider;
import androidx.core.content.ContextCompat;
import com.google.common.util.concurrent.ListenableFuture;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ProcessCameraProviderHostApi;
import java.util.ArrayList;
import java.util.List;

public class ProcessCameraProviderHostApiImpl implements ProcessCameraProviderHostApi {
  private final BinaryMessenger binaryMessenger;
  private final InstanceManager instanceManager;

  private Context context;

  public ProcessCameraProviderHostApiImpl(
      BinaryMessenger binaryMessenger, InstanceManager instanceManager, Context context) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
    this.context = context;
  }

  /**
   * Sets the context that the {@code ProcessCameraProvider} will use to attach the lifecycle of the
   * camera to.
   *
   * <p>If using the camera plugin in an add-to-app context, ensure that a new instance of the
   * {@code ProcessCameraProvider} is fetched via {@code #getInstance} anytime the context changes.
   */
  public void setContext(Context context) {
    this.context = context;
  }

  /**
   * Returns the instance of the ProcessCameraProvider to manage the lifecycle of the camera for the
   * current {@code Context}.
   */
  @Override
  public void getInstance(GeneratedCameraXLibrary.Result<Long> result) {
    ListenableFuture<ProcessCameraProvider> processCameraProviderFuture =
        ProcessCameraProvider.getInstance(context);

    processCameraProviderFuture.addListener(
        () -> {
          try {
            // Camera provider is now guaranteed to be available.
            ProcessCameraProvider processCameraProvider = processCameraProviderFuture.get();

            if (!instanceManager.containsInstance(processCameraProvider)) {
              final ProcessCameraProviderFlutterApiImpl flutterApi =
                  new ProcessCameraProviderFlutterApiImpl(binaryMessenger, instanceManager);
              flutterApi.create(processCameraProvider, reply -> {});
            }
            result.success(instanceManager.getIdentifierForStrongReference(processCameraProvider));
          } catch (Exception e) {
            result.error(e);
          }
        },
        ContextCompat.getMainExecutor(context));
  }

  /** Returns cameras available to the ProcessCameraProvider. */
  @Override
  public List<Long> getAvailableCameraInfos(@NonNull Long identifier) {
    ProcessCameraProvider processCameraProvider =
        (ProcessCameraProvider) instanceManager.getInstance(identifier);

    List<CameraInfo> availableCameras = processCameraProvider.getAvailableCameraInfos();
    List<Long> availableCamerasIds = new ArrayList<Long>();
    final CameraInfoFlutterApiImpl cameraInfoFlutterApi =
        new CameraInfoFlutterApiImpl(binaryMessenger, instanceManager);

    for (CameraInfo cameraInfo : availableCameras) {
      cameraInfoFlutterApi.create(cameraInfo, result -> {});
      availableCamerasIds.add(instanceManager.getIdentifierForStrongReference(cameraInfo));
    }
    return availableCamerasIds;
  }
}
