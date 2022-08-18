// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.app.Activity;
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

  private Activity activity;

  public ProcessCameraProviderHostApiImpl(
      BinaryMessenger binaryMessenger, InstanceManager instanceManager, Activity activity) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
    this.activity = activity;
  }

  // Returns the instance of the ProcessCameraProvider.
  @Override
  public void getInstance(GeneratedCameraXLibrary.Result<Long> result) {
    ListenableFuture<ProcessCameraProvider> cameraProviderFuture =
        ProcessCameraProvider.getInstance(activity);

    cameraProviderFuture.addListener(
        () -> {
          try {
            // Camera provider is now guaranteed to be available
            ProcessCameraProvider processCameraProvider = cameraProviderFuture.get();

            if (!instanceManager.containsInstance(processCameraProvider)) {
              // If cameraProvider is already defined, this method will have no effect.
              final ProcessCameraProviderFlutterApiImpl flutterApi =
                  new ProcessCameraProviderFlutterApiImpl(binaryMessenger, instanceManager);
              flutterApi.create(processCameraProvider, reply -> {});
            }
          } catch (Exception e) {
            result.error(e);
          }
        },
        ContextCompat.getMainExecutor(activity));
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
      cameraInfoFlutterApi.create(cameraInfo, result -> {});
      Long cameraInfoId = instanceManager.getIdentifierForStrongReference(cameraInfo);
      availableCamerasIds.add(cameraInfoId);
    }
    return availableCamerasIds;
  }
}
