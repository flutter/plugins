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
import java.util.Objects;

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

  // Returns the instance of the ProcessCameraProvider.
  @Override
  public void getInstance(GeneratedCameraXLibrary.Result<Long> result) {
    ListenableFuture<ProcessCameraProvider> cameraProviderFuture =
        ProcessCameraProvider.getInstance(context);

    cameraProviderFuture.addListener(
        () -> {
          try {
            // Camera provider is now guaranteed to be available
            ProcessCameraProvider processCameraProvider = cameraProviderFuture.get();

            if (!instanceManager.containsInstance(processCameraProvider)) {
              // If cameraProvider is already defined, this method will have no effect.
              final ProcessCameraProviderFlutterApiImpl flutterApi =
                  new ProcessCameraProviderFlutterApiImpl(binaryMessenger, instanceManager);

              long processCameraProviderId =
                  instanceManager.addHostCreatedInstance(processCameraProvider);
              flutterApi.create(processCameraProvider, reply -> {});

              result.success(processCameraProviderId);
            }
          } catch (Exception e) {
            result.error(e);
          }
        },
        ContextCompat.getMainExecutor(context));
  }

  // Returns cameras available to the ProcessCameraProvider.
  @Override
  public List<Long> getAvailableCameraInfos(@NonNull Long instanceId) {
    ProcessCameraProvider processCameraProvider =
        (ProcessCameraProvider) instanceManager.getInstance(instanceId); // may return null?

    List<CameraInfo> availableCameras = processCameraProvider.getAvailableCameraInfos();
    List<Long> availableCamerasIds = new ArrayList<Long>();
    final CameraInfoFlutterApiImpl cameraInfoFlutterApi =
        new CameraInfoFlutterApiImpl(binaryMessenger, instanceManager);

    for (CameraInfo cameraInfo : availableCameras) {
      long cameraInfoId = instanceManager.addHostCreatedInstance(cameraInfo);
      cameraInfoFlutterApi.create(cameraInfo, result -> {});
      Long cameraInfoId2 = instanceManager.getIdentifierForStrongReference(cameraInfo);
      availableCamerasIds.add(cameraInfoId);
    }
    return availableCamerasIds;
  }
}
